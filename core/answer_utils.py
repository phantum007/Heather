from decimal import Decimal, InvalidOperation, ROUND_DOWN


THREE_DECIMAL_PLACES = Decimal("0.001")


def _normalize_text_answer(value) -> str:
    return str(value or "").strip()


def _normalize_numeric_answer(value) -> str | None:
    text = _normalize_text_answer(value)
    if not text:
        return None

    candidate = text.replace(",", "")
    try:
        decimal_value = Decimal(candidate)
    except InvalidOperation:
        return None

    if decimal_value.as_tuple().exponent < -3:
        decimal_value = decimal_value.quantize(THREE_DECIMAL_PLACES, rounding=ROUND_DOWN)

    normalized = format(decimal_value.normalize(), "f")

    if "." in normalized:
        normalized = normalized.rstrip("0").rstrip(".")
    return normalized or "0"


def answers_match(student_answer, correct_answer) -> bool:
    student_text = _normalize_text_answer(student_answer)
    correct_text = _normalize_text_answer(correct_answer)

    if not student_text or not correct_text:
        return False

    student_numeric = _normalize_numeric_answer(student_text)
    correct_numeric = _normalize_numeric_answer(correct_text)
    if student_numeric is not None and correct_numeric is not None:
        return student_numeric == correct_numeric

    return student_text.lower() == correct_text.lower()
