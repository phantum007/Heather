import re
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from fractions import Fraction

from django.core.management.base import BaseCommand
from django.db import transaction

from core.models import CurriculumQuestion


SUM_TRACKS = {
    "Reading Abacus",
    "Listening Abacus",
    "Listening Anzan",
    "Flash Anzan",
}

PRODUCT_TRACKS = {
    "Multiplication Abacus",
    "Multiplication Anzan",
}

QUOTIENT_TRACKS = {
    "Division Abacus",
    "Division Anzan",
}

NUMBER_RE = re.compile(r"[+-]?\d+(?:,\d+)*(?:\.\d+)?")


def _format_value(value: Decimal) -> str:
    normalized = value.normalize()
    text = format(normalized, "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text or "0"


def _is_terminating_fraction(value: Fraction) -> bool:
    denominator = value.denominator
    for factor in (2, 5):
        while denominator % factor == 0 and denominator > 1:
            denominator //= factor
    return denominator == 1


def _parse_numeric_lines(question_text: str) -> list[Decimal] | None:
    values = []
    for raw_line in question_text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if not NUMBER_RE.fullmatch(line):
            return None
        try:
            values.append(Decimal(line.replace(",", "")))
        except InvalidOperation:
            return None
    return values or None


def _infer_answer(question: CurriculumQuestion) -> str | None:
    if not question.unit_id or not getattr(question.unit, "sub_lesson", None):
        return None

    track_name = question.unit.sub_lesson.sub_lesson_name
    values = _parse_numeric_lines(question.question_text or "")
    if not values:
        return None

    if track_name in SUM_TRACKS:
        return _format_value(sum(values, Decimal("0")))

    if track_name in PRODUCT_TRACKS and len(values) == 2:
        return _format_value(values[0] * values[1])

    if track_name in QUOTIENT_TRACKS and len(values) == 2 and values[1] != 0:
        quotient = Fraction(values[0]) / Fraction(values[1])
        if _is_terminating_fraction(quotient):
            return _format_value(Decimal(quotient.numerator) / Decimal(quotient.denominator))
        rounded = (Decimal(quotient.numerator) / Decimal(quotient.denominator)).quantize(
            Decimal("0.001"),
            rounding=ROUND_HALF_UP,
        )
        return _format_value(rounded)

    return None


class Command(BaseCommand):
    help = "Backfill missing curriculum question answers based on question text and track type."

    def add_arguments(self, parser):
        parser.add_argument(
            "--apply",
            action="store_true",
            help="Persist the inferred answers. Without this flag the command runs as a dry run.",
        )
        parser.add_argument(
            "--limit",
            type=int,
            default=None,
            help="Optional cap on the number of null-answer rows to inspect.",
        )

    def handle(self, *args, **options):
        queryset = CurriculumQuestion.objects.filter(answer_text__isnull=True).select_related("unit__sub_lesson").order_by("id")
        limit = options["limit"]
        if limit:
            queryset = queryset[:limit]

        updates = []
        skipped = []

        for question in queryset:
            inferred_answer = _infer_answer(question)
            if inferred_answer is None:
                if len(skipped) < 10:
                    skipped.append(
                        {
                            "id": question.id,
                            "track": question.unit.sub_lesson.sub_lesson_name if question.unit_id and getattr(question.unit, "sub_lesson", None) else None,
                            "question_text": question.question_text,
                        }
                    )
                continue
            question.answer_text = inferred_answer
            updates.append(question)

        self.stdout.write(f"rows_checked={queryset.count()}")
        self.stdout.write(f"rows_fillable={len(updates)}")
        self.stdout.write(f"rows_skipped={queryset.count() - len(updates)}")
        if skipped:
            self.stdout.write(f"sample_skipped={skipped}")

        if not options["apply"] or not updates:
            return

        with transaction.atomic():
            CurriculumQuestion.objects.bulk_update(updates, ["answer_text"], batch_size=1000)

        self.stdout.write(self.style.SUCCESS(f"Updated {len(updates)} curriculum question answers."))
