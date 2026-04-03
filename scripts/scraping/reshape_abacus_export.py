#!/usr/bin/env python3
import json
import re
from pathlib import Path


INPUT_PATH = Path("abacus_assigned_lessons_export.json")


SUB_LESSON_NAME_BY_TYPE = {
    "read_abacus": "Reading Abacus",
    "list_abacus": "Listening Abacus",
    "list_anzan": "Listening Anzan",
    "flash_abacus": "Flash Abacus",
    "flash_anzan": "Flash Anzan",
    "mult_abacus": "Multiplication Abacus",
    "mult_anzan": "Multiplication Anzan",
    "div_abacus": "Division Abacus",
    "div_anzan": "Division Anzan",
}


def normalize_answer(raw_answer):
    if raw_answer is None:
        return None
    text = str(raw_answer).strip()
    if text.endswith(".000000"):
        text = text[:-7]
    return text


def lesson_order(lesson_title: str, fallback: int) -> int:
    match = re.search(r"Lesson\s+(\d+)", lesson_title or "")
    return int(match.group(1)) if match else fallback


def normalize_lesson_name(lesson_title: str | None) -> str | None:
    title = " ".join((lesson_title or "").split())
    if not title:
        return lesson_title
    matches = re.findall(r"(\d+)", title)
    if matches:
        return matches[-1]
    return title


def unit_name(index: int) -> str:
    return str(index)


def normalize_sub_lesson_name(track_type: str | None, title: str | None) -> str | None:
    if track_type in SUB_LESSON_NAME_BY_TYPE:
        return SUB_LESSON_NAME_BY_TYPE[track_type]

    text = " ".join((title or "").split()).lower()
    if not text:
        return title

    if "reading" in text and "abacus" in text:
        return "Reading Abacus"
    if "listening" in text and "abacus" in text:
        return "Listening Abacus"
    if "listening" in text and "anzan" in text:
        return "Listening Anzan"
    if "flash" in text and "anzan" in text:
        return "Flash Anzan"
    if "flash" in text and "abacus" in text:
        return "Flash Abacus"
    if ("multiplication" in text or "mutiplication" in text) and "anzan" in text:
        return "Multiplication Anzan"
    if ("multiplication" in text or "mutiplication" in text) and "abacus" in text:
        return "Multiplication Abacus"
    if ("multiplication" in text or "mutiplication" in text):
        return "Multiplication Abacus"
    if ("division" in text or "divsion" in text) and "anzan" in text:
        return "Division Anzan"
    if ("division" in text or "divsion" in text) and "abacus" in text:
        return "Division Abacus"
    if "division" in text or "divsion" in text:
        return "Division Abacus"

    return title


def main() -> None:
    with INPUT_PATH.open() as handle:
        source = json.load(handle)

    lessons_out = []
    first_grade = None

    for lesson_index, lesson in enumerate(source.get("lessons", []), start=1):
        grade_value = lesson.get("grade")
        if first_grade is None:
            first_grade = grade_value

        sub_lessons_out = []
        for sub_lesson in lesson.get("sub_lessons", []):
            canonical_sub_lesson_name = normalize_sub_lesson_name(
                sub_lesson.get("type"),
                sub_lesson.get("title"),
            )
            units_out = []

            for unit_index, unit in enumerate(sub_lesson.get("units", []), start=1):
                questions_out = []
                for question_index, question in enumerate(unit.get("questions", []), start=1):
                    questions_out.append(
                        {
                            "source_key": question.get("key"),
                            "order": question_index,
                            "question_text": question.get("question_text"),
                            "answer_text": normalize_answer(question.get("answer")),
                            "rows": question.get("rows", []),
                        }
                    )

                units_out.append(
                    {
                        "source_id": unit.get("id"),
                        "order": unit_index,
                        "unit_name": unit_name(unit_index),
                        "questions": questions_out,
                    }
                )

            sub_lessons_out.append(
                {
                    "source_id": sub_lesson.get("id"),
                    "source_title": sub_lesson.get("title"),
                    "sub_lesson_name": canonical_sub_lesson_name,
                    "order": sub_lesson.get("position"),
                    "units": units_out,
                }
            )

        lessons_out.append(
            {
                "source_id": lesson.get("id"),
                "lesson_name": normalize_lesson_name(lesson.get("title")),
                "order": lesson_order(lesson.get("title"), lesson_index),
                "sub_lessons": sub_lessons_out,
            }
        )

    payload = {
        "source": source.get("source"),
        "scraped_at": source.get("scraped_at"),
        "grade": first_grade,
        "lessons": lessons_out,
    }

    output_path = Path(f"abacus_grade_{first_grade}_curriculum.json")
    with output_path.open("w") as handle:
        json.dump(payload, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
