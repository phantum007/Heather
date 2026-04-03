import fs from "fs";

const API_BASE = "https://api.abacusmentalmath.com";
const USERNAME = process.env.ABACUS_USERNAME || "speed";
const PASSWORD = process.env.ABACUS_PASSWORD || "password091325";
const LANGUAGE_KEY = process.env.ABACUS_LANGUAGE_KEY || "en";
const OUTPUT_PATH = process.env.ABACUS_OUTPUT || "abacus_assigned_lessons_export.json";
const LESSON_TYPE = process.env.ABACUS_LESSON_TYPE || "lesson";
const CONCURRENCY = Number(process.env.ABACUS_CONCURRENCY || 8);

async function api(path, { method = "GET", token, body } = {}) {
  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  const text = await response.text();
  let payload;
  try {
    payload = text ? JSON.parse(text) : null;
  } catch {
    payload = text;
  }

  if (!response.ok) {
    throw new Error(`${method} ${path} failed: ${response.status} ${JSON.stringify(payload).slice(0, 500)}`);
  }

  return payload;
}

function mapParticlesToQuestions(payload) {
  const particles = payload?.data?.particles;
  if (!Array.isArray(particles)) {
    return [];
  }

  const grouped = new Map();
  for (const particle of particles) {
    const key = particle.key;
    if (!grouped.has(key)) {
      grouped.set(key, {
        key,
        rows: [],
        answer: particle.answer?.student_answer ?? null,
        is_correct: particle.answer?.is_correct ?? null,
      });
    }
    const entry = grouped.get(key);
    entry.rows.push(String(particle.value).replace(".000000", ""));
    if (particle.answer) {
      entry.answer = particle.answer.student_answer;
      entry.is_correct = particle.answer.is_correct;
    }
  }

  return [...grouped.values()]
    .sort((a, b) => Number(a.key) - Number(b.key))
    .map((item) => ({
      key: item.key,
      question_text: item.rows.join("\n"),
      rows: item.rows,
      answer: item.answer,
      is_correct: item.is_correct,
    }));
}

async function mapLimit(items, limit, mapper) {
  const results = new Array(items.length);
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < items.length) {
      const current = nextIndex;
      nextIndex += 1;
      results[current] = await mapper(items[current], current);
    }
  }

  const workers = Array.from({ length: Math.min(limit, items.length) }, () => worker());
  await Promise.all(workers);
  return results;
}

async function main() {
  console.log(`[scrape] login for ${USERNAME}`);
  const login = await api("/login", {
    method: "POST",
    body: {
      username: USERNAME,
      password: PASSWORD,
      language_key: LANGUAGE_KEY,
    },
  });
  const token = login.access_token;

  const profile = await api("/profile", { token });
  const lessonIndex = await api(`/lessons/index/${LESSON_TYPE}?page=1&order=position`, { token });
  const lessons = Array.isArray(lessonIndex?.data) ? lessonIndex.data : [];
  console.log(`[scrape] lessons found: ${lessons.length}`);

  const lessonResults = await mapLimit(lessons, 3, async (lesson, lessonIdx) => {
    console.log(`[scrape] lesson ${lessonIdx + 1}/${lessons.length}: ${lesson.title}`);
    const lessonDetails = await api(`/lessons/${lesson.id}?include=videos,staticFiles`, { token });
    const topicsPayload = await api(`/lessons/${lesson.id}/topics?page=1&include=units`, { token });
    const topics = Array.isArray(topicsPayload?.data) ? topicsPayload.data : [];

    const topicResults = await mapLimit(topics, 3, async (topic, topicIdx) => {
      console.log(`[scrape]   topic ${topicIdx + 1}/${topics.length}: ${topic.title}`);
      const unitsPayload = await api(`/lessons/${lesson.id}/topics/${topic.id}/units`, { token });
      const units = Array.isArray(unitsPayload?.data) ? unitsPayload.data : [];

      const unitResults = await mapLimit(units, CONCURRENCY, async (unit, unitIdx) => {
        console.log(`[scrape]     unit ${unitIdx + 1}/${units.length}: ${unit.id}`);
        const particlePayload = await api(`/lessons/${lesson.id}/topics/${topic.id}/units/${unit.id}/list-particles`, { token });
        return {
          id: unit.id,
          title: unit.title ?? unit.name ?? null,
          position: unit.position ?? null,
          particles_count: unit.particles_count ?? null,
          questions: mapParticlesToQuestions(particlePayload),
        };
      });

      return {
        id: topic.id,
        title: topic.title,
        type: topic.type,
        position: topic.position,
        units: unitResults,
      };
    });

    return {
      id: lesson.id,
      title: lesson.title,
      grade: lesson.grade,
      type: lesson.type,
      position: lesson.position,
      videos: lessonDetails?.data?.videos ?? lessonDetails?.videos ?? [],
      static_files: lessonDetails?.data?.staticFiles ?? lessonDetails?.data?.static_files ?? lessonDetails?.staticFiles ?? [],
      sub_lessons: topicResults,
    };
  });

  const output = {
    scraped_at: new Date().toISOString(),
    source: "https://client.abacusmentalmath.com/",
    account: USERNAME,
    lesson_type: LESSON_TYPE,
    profile: profile?.data ?? profile,
    lessons: lessonResults,
  };

  fs.writeFileSync(OUTPUT_PATH, `${JSON.stringify(output, null, 2)}\n`);
  console.log(`[scrape] wrote ${OUTPUT_PATH}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
