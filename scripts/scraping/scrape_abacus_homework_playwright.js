const fs = require("fs");
const path = require("path");
const { chromium } = require("/tmp/abacus_scrape/node_modules/playwright");

const USERNAME = process.env.ABACUS_USERNAME || "speed";
const PASSWORD = process.env.ABACUS_PASSWORD || "password091325";
const OUTPUT_PATH = process.env.ABACUS_OUTPUT || path.resolve(process.cwd(), "abacus_homework_browser_export.json");

const API_BASE = "https://api.abacusmentalmath.com";

function safeJsonParse(text) {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

async function clickIfVisible(page, selectors) {
  for (const selector of selectors) {
    const locator = page.locator(selector).first();
    if (await locator.count()) {
      try {
        if (await locator.isVisible({ timeout: 500 })) {
          await locator.click({ timeout: 1500 });
          return true;
        }
      } catch {}
    }
  }
  return false;
}

async function waitForApi(page, predicate, action, timeout = 15000) {
  const waiter = page.waitForResponse(async (response) => {
    const url = response.url();
    return predicate(url, response);
  }, { timeout });
  await action();
  return waiter;
}

async function dismissPopup(page) {
  const popupCandidates = [
    'button:has-text("Ok")',
    'button:has-text("OK")',
    'button[aria-label="Close"]',
    '.modal button.close',
    '.modal [class*="close"]',
    '.modal svg',
  ];

  for (let i = 0; i < 3; i += 1) {
    const clicked = await clickIfVisible(page, popupCandidates);
    if (!clicked) {
      break;
    }
    await page.waitForTimeout(800);
  }
}

async function login(page) {
  await page.goto("https://client.abacusmentalmath.com/login", { waitUntil: "networkidle" });

  const userField = page.locator('input[type="text"], input[name="username"]').first();
  const passwordField = page.locator('input[type="password"]').first();
  await userField.fill(USERNAME);
  await passwordField.fill(PASSWORD);

  const loginResponsePromise = page.waitForResponse((response) => response.url() === `${API_BASE}/login` && response.request().method() === "POST", { timeout: 15000 });
  await clickIfVisible(page, ['button:has-text("Log in")', 'button:has-text("Login")', 'button:has-text("Iniciar sesión")', 'button[type="submit"]']);
  await loginResponsePromise;
  await page.waitForLoadState("networkidle");
}

async function openHomework(page) {
  if (!page.url().includes("/lessons/homework")) {
    await clickIfVisible(page, ['a[href="/lessons/homework"]', 'a:has-text("My Homework")']);
    await page.waitForLoadState("networkidle");
  }
  await dismissPopup(page);
}

async function collectLessonCards(page) {
  const lessonData = await page.evaluate(() => {
    const buttons = Array.from(document.querySelectorAll("button, a"));
    return buttons
      .map((button) => {
        const text = (button.innerText || "").trim();
        const card = button.closest("div");
        const containerText = card ? card.innerText || "" : text;
        if (!/let'?s go/i.test(text)) {
          return null;
        }
        const titleMatch = containerText.match(/Lesson[^\n]*/i);
        return {
          title: titleMatch ? titleMatch[0].trim() : "Unknown lesson",
          text,
        };
      })
      .filter(Boolean);
  });
  return lessonData;
}

async function collectTopicCards(page) {
  return page.evaluate(() => {
    const cards = Array.from(document.querySelectorAll("div, button, a"));
    return cards
      .map((node) => {
        const text = (node.innerText || "").trim();
        if (!text || !/units available/i.test(text)) {
          return null;
        }
        const lines = text.split("\n").map((line) => line.trim()).filter(Boolean);
        return {
          title: lines[0] || "",
          summary: lines[1] || "",
        };
      })
      .filter(Boolean)
      .filter((item, index, list) => list.findIndex((x) => x.title === item.title && x.summary === item.summary) === index);
  });
}

async function collectUnits(page) {
  return page.evaluate(() => {
    const candidates = Array.from(document.querySelectorAll("button, div, a"));
    const units = [];
    for (const node of candidates) {
      const text = (node.innerText || "").trim();
      if (!text) continue;
      if (/^\d+$/.test(text) || /^Unit\s+\d+/i.test(text)) {
        units.push({
          label: text,
        });
      }
    }
    return units.filter((item, index, list) => list.findIndex((x) => x.label === item.label) === index);
  });
}

async function collectVisibleQuestion(page) {
  return page.evaluate(() => {
    const input = document.querySelector('input[placeholder*="Type here"], input[type="text"]');
    const stageCandidates = Array.from(document.querySelectorAll("div, p, span"))
      .map((node) => (node.innerText || "").trim())
      .filter(Boolean)
      .filter((text) => text.includes("\n") || /^[-+xX÷/\d\s]+$/.test(text))
      .sort((a, b) => b.length - a.length);

    return {
      prompt: stageCandidates[0] || null,
      hasInput: Boolean(input),
    };
  });
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 1200 } });

  const apiCapture = {
    login: null,
    profile: null,
    homeworkLessons: [],
    lessonTopics: [],
    topicUnits: [],
    unitQuestions: [],
  };

  page.on("response", async (response) => {
    const url = response.url();
    if (!url.startsWith(API_BASE)) return;
    const body = safeJsonParse(await response.text());
    if (!body) return;

    if (url === `${API_BASE}/login`) apiCapture.login = body;
    else if (url === `${API_BASE}/profile`) apiCapture.profile = body;
    else if (url.includes("/lessons/index/homework")) apiCapture.homeworkLessons.push(body);
    else if (/\/lessons\/\d+\/topics(\?|$)/.test(url)) apiCapture.lessonTopics.push({ url, body });
    else if (/\/lessons\/\d+\/topics\/\d+\/units(\?|$)/.test(url)) apiCapture.topicUnits.push({ url, body });
    else if (/\/lessons\/\d+\/topics\/\d+\/units\/\d+\/list-particles/.test(url)) apiCapture.unitQuestions.push({ url, body });
  });

  await login(page);
  await openHomework(page);

  const result = {
    scraped_at: new Date().toISOString(),
    account: USERNAME,
    current_url: page.url(),
    visible_lessons: await collectLessonCards(page),
    captured_api: apiCapture,
    lesson_walkthrough: [],
  };

  const lessonButtons = page.locator('button:has-text("Let\'s Go!"), a:has-text("Let\'s Go!")');
  const lessonCount = await lessonButtons.count();
  const maxLessons = Math.min(lessonCount, 3);

  for (let lessonIndex = 0; lessonIndex < maxLessons; lessonIndex += 1) {
    await openHomework(page);
    const freshLessonButtons = page.locator('button:has-text("Let\'s Go!"), a:has-text("Let\'s Go!")');
    const lessonCardTexts = await collectLessonCards(page);
    const lessonTitle = lessonCardTexts[lessonIndex] ? lessonCardTexts[lessonIndex].title : `Lesson ${lessonIndex + 1}`;

    const topicsResponse = await waitForApi(
      page,
      (url) => /\/lessons\/\d+\/topics(\?|$)/.test(url),
      async () => {
        await freshLessonButtons.nth(lessonIndex).click();
      },
      20000
    );

    await page.waitForLoadState("networkidle");
    await dismissPopup(page);
    const topicsPayload = safeJsonParse(await topicsResponse.text()) || {};
    const topicsData = Array.isArray(topicsPayload.data) ? topicsPayload.data : [];
    const lessonEntry = {
      title: lessonTitle,
      topics: [],
    };

    const topicCards = await collectTopicCards(page);
    const maxTopics = Math.min(topicsData.length || topicCards.length, 3);

    for (let topicIndex = 0; topicIndex < maxTopics; topicIndex += 1) {
      const topicMeta = topicsData[topicIndex] || {};
      const topicTitle = topicCards[topicIndex]?.title || topicMeta.title || topicMeta.name || `Topic ${topicIndex + 1}`;

      const topicUnitsResponse = await waitForApi(
        page,
        (url) => /\/lessons\/\d+\/topics\/\d+\/units(\?|$)/.test(url),
        async () => {
          const topicLocator = page.locator(`text=${topicTitle}`).first();
          await topicLocator.click();
        },
        20000
      );

      await page.waitForLoadState("networkidle");
      const unitsPayload = safeJsonParse(await topicUnitsResponse.text()) || {};
      const unitsData = Array.isArray(unitsPayload.data) ? unitsPayload.data : [];
      const topicEntry = {
        title: topicTitle,
        units: [],
      };

      const maxUnits = Math.min(unitsData.length, 3);
      for (let unitIndex = 0; unitIndex < maxUnits; unitIndex += 1) {
        const unitMeta = unitsData[unitIndex] || {};
        const unitLabel = unitMeta.title || unitMeta.name || String(unitMeta.position || unitIndex + 1);

        const unitQuestionsResponse = await waitForApi(
          page,
          (url) => /\/lessons\/\d+\/topics\/\d+\/units\/\d+\/list-particles/.test(url),
          async () => {
            const direct = page.locator(`text=${unitLabel}`).first();
            await direct.click();
            const startClicked = await clickIfVisible(page, ['button:has-text("Start")', 'button:has-text("Let\'s Go!")']);
            if (!startClicked) {
              await page.waitForTimeout(1000);
            }
          },
          20000
        );

        await page.waitForLoadState("networkidle");
        const questionPayload = safeJsonParse(await unitQuestionsResponse.text()) || {};
        const questions = (questionPayload.data && questionPayload.data.particles_text) || questionPayload.data || [];

        topicEntry.units.push({
          label: unitLabel,
          visible_question: await collectVisibleQuestion(page),
          raw_questions: questions,
        });

        await clickIfVisible(page, ['button:has-text("×")', 'button:has-text("Close")', 'button[aria-label="Close"]']);
        await page.waitForTimeout(800);
      }

      lessonEntry.topics.push(topicEntry);
      await page.goBack({ waitUntil: "networkidle" }).catch(() => {});
      await page.waitForTimeout(800);
    }

    result.lesson_walkthrough.push(lessonEntry);
    await page.goto("https://client.abacusmentalmath.com/lessons/homework", { waitUntil: "networkidle" });
    await dismissPopup(page);
  }

  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(result, null, 2));
  console.log(`Wrote ${OUTPUT_PATH}`);

  await browser.close();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
