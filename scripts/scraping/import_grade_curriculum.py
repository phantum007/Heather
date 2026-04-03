#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import sys

import django


def parse_args():
    parser = argparse.ArgumentParser(description="Import reshaped curriculum JSON into the local database.")
    parser.add_argument(
        "--input",
        default="abacus_grade_10_curriculum.json",
        help="Path to the reshaped curriculum JSON file.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    input_path = Path(args.input)
    if not input_path.exists():
        raise SystemExit(f"Input file not found: {input_path}")

    import os

    repo_root = Path(__file__).resolve().parent.parent
    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
    django.setup()

    from django.db import transaction
    from core.models import CurriculumQuestion, Grade, LessonType, SubLesson, SubLessonTypeMaster, Unit

    payload = json.loads(input_path.read_text())
    grade_name = str(payload["grade"])

    if Grade.objects.filter(grade_name=grade_name).exists():
        raise SystemExit(f"Grade {grade_name} already exists. Aborting to avoid duplicate imports.")

    track_type_map = {
        item.type_name: item
        for item in SubLessonTypeMaster.objects.all()
    }

    missing_track_types = sorted(
        {
            sub_lesson["sub_lesson_name"]
            for lesson in payload["lessons"]
            for sub_lesson in lesson["sub_lessons"]
            if sub_lesson["sub_lesson_name"] not in track_type_map
        }
    )
    if missing_track_types:
        raise SystemExit(f"Missing SubLessonTypeMaster records for: {', '.join(missing_track_types)}")

    lesson_count = 0
    sub_lesson_count = 0
    unit_count = 0
    question_count = 0

    with transaction.atomic():
        grade = Grade.objects.create(grade_name=grade_name)

        for lesson_payload in payload["lessons"]:
            lesson = LessonType.objects.create(
                grade_id=grade.id,
                lesson_name=lesson_payload["lesson_name"],
            )
            lesson_count += 1

            for sub_lesson_payload in lesson_payload["sub_lessons"]:
                track_type = track_type_map[sub_lesson_payload["sub_lesson_name"]]
                sub_lesson = SubLesson.objects.create(
                    lesson_type_id=lesson.id,
                    sub_lesson_type_master_id=track_type.id,
                    sub_lesson_name=sub_lesson_payload["sub_lesson_name"],
                )
                sub_lesson_count += 1

                for unit_payload in sub_lesson_payload["units"]:
                    unit = Unit.objects.create(
                        sub_lesson_id=sub_lesson.id,
                        unit_name=unit_payload["unit_name"],
                    )
                    unit_count += 1

                    question_rows = []
                    for question_payload in unit_payload["questions"]:
                        question_rows.append(
                            CurriculumQuestion(
                                unit_id=unit.id,
                                question_text=question_payload["question_text"],
                                answer_text=question_payload["answer_text"],
                                order=question_payload["order"],
                            )
                        )
                    if question_rows:
                        CurriculumQuestion.objects.bulk_create(question_rows)
                        question_count += len(question_rows)

    print(
        f"Imported grade {grade_name}: "
        f"{lesson_count} lessons, {sub_lesson_count} sub-lessons, {unit_count} units, {question_count} questions."
    )


if __name__ == "__main__":
    main()
