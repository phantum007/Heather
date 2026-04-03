#!/usr/bin/env python3
import argparse
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Any


API_BASE = "https://api.abacusmentalmath.com"
DEFAULT_LESSON_TYPES = ["lesson", "classroom", "word_problems", "final"]


class AbacusClient:
    def __init__(self, username: str, password: str, language_key: str = "en", timeout: int = 30) -> None:
        self.username = username
        self.password = password
        self.language_key = language_key
        self.timeout = timeout
        self.token: str | None = None

    def _headers(self) -> dict[str, str]:
        headers = {
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
        }
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        return headers

    def _request(self, method: str, path: str, *, params: dict[str, Any] | None = None, payload: dict[str, Any] | None = None) -> Any:
        url = f"{API_BASE}{path}"
        if params:
            query = urllib.parse.urlencode(params, doseq=True)
            url = f"{url}?{query}"

        data = None
        if payload is not None:
            data = json.dumps(payload).encode("utf-8")

        request = urllib.request.Request(url, data=data, headers=self._headers(), method=method)
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                body = response.read().decode("utf-8")
        except urllib.error.HTTPError as exc:
            error_body = exc.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"{method} {path} failed with HTTP {exc.code}: {error_body}") from exc
        except urllib.error.URLError as exc:
            raise RuntimeError(f"{method} {path} failed: {exc}") from exc

        if not body:
            return None
        return json.loads(body)

    def login(self) -> None:
        response = self._request(
            "POST",
            "/login",
            payload={
                "username": self.username,
                "password": self.password,
                "language_key": self.language_key,
            },
        )
        token = response.get("access_token")
        if not token:
            raise RuntimeError("Login succeeded but access_token was missing from the response.")
        self.token = token

    def profile(self) -> dict[str, Any]:
        response = self._request("GET", "/profile")
        return response.get("data", response)

    def lessons_index(self, lesson_type: str, page: int = 1) -> dict[str, Any]:
        response = self._request(
            "GET",
            f"/lessons/index/{lesson_type}",
            params={"page": page, "order": "position"},
        )
        return response

    def lesson_details(self, lesson_id: int) -> dict[str, Any]:
        response = self._request(
            "GET",
            f"/lessons/{lesson_id}",
            params={"include": "videos,staticFiles"},
        )
        return response.get("data", response)

    def topic_page(self, lesson_id: int, page: int = 1) -> dict[str, Any]:
        response = self._request(
            "GET",
            f"/lessons/{lesson_id}/topics",
            params={"page": page, "include": "units"},
        )
        return response

    def topic_units(self, lesson_id: int, topic_id: int) -> dict[str, Any]:
        response = self._request("GET", f"/lessons/{lesson_id}/topics/{topic_id}/units")
        return response

    def list_particles(self, lesson_id: int, topic_id: int, unit_id: int) -> dict[str, Any]:
        response = self._request(
            "GET",
            f"/lessons/{lesson_id}/topics/{topic_id}/units/{unit_id}/list-particles",
        )
        return response


def _paginate(fetch_page) -> list[dict[str, Any]]:
    page = 1
    items: list[dict[str, Any]] = []
    seen = 0
    while True:
        response = fetch_page(page)
        data = response.get("data", [])
        if not isinstance(data, list) or not data:
            break
        items.extend(data)
        current_seen = len(items)
        if current_seen == seen:
            break
        seen = current_seen
        meta = response.get("meta") or {}
        last_page = meta.get("last_page")
        if last_page and page >= last_page:
            break
        page += 1
    return items


def _extract_questions(payload: dict[str, Any]) -> list[dict[str, Any]]:
    data = payload.get("data", payload)
    particles_text = data.get("particles_text") if isinstance(data, dict) else None
    if isinstance(particles_text, list):
        questions = []
        for item in particles_text:
            questions.append(
                {
                    "key": item.get("key"),
                    "question": item.get("question"),
                    "measure": item.get("measure"),
                    "answer": item.get("answer"),
                }
            )
        return questions

    particles = data.get("particles") if isinstance(data, dict) else None
    if isinstance(particles, list):
        grouped: dict[Any, dict[str, Any]] = {}
        for particle in particles:
            key = particle.get("key")
            entry = grouped.setdefault(
                key,
                {
                    "key": key,
                    "rows": [],
                    "answer": particle.get("answer", {}).get("student_answer") if isinstance(particle.get("answer"), dict) else None,
                    "is_correct": particle.get("answer", {}).get("is_correct") if isinstance(particle.get("answer"), dict) else None,
                },
            )
            entry["rows"].append(particle.get("value"))
            if isinstance(particle.get("answer"), dict):
                entry["answer"] = particle["answer"].get("student_answer")
                entry["is_correct"] = particle["answer"].get("is_correct")

        questions = []
        for key in sorted(grouped.keys()):
            item = grouped[key]
            row_values = [str(value).replace(".000000", "") for value in item["rows"] if value is not None]
            questions.append(
                {
                    "key": key,
                    "question_text": "\n".join(row_values),
                    "rows": row_values,
                    "answer": item["answer"],
                    "is_correct": item["is_correct"],
                }
            )
        return questions

    if isinstance(data, list):
        return data

    return []


def build_export(client: AbacusClient, lesson_types: list[str]) -> dict[str, Any]:
    profile = client.profile()
    export: dict[str, Any] = {
        "scraped_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "source": "https://client.abacusmentalmath.com/",
        "profile": profile,
        "lesson_types": [],
    }

    for lesson_type in lesson_types:
        lessons = _paginate(lambda page: client.lessons_index(lesson_type, page))
        print(f"[scrape] lesson type={lesson_type} lessons={len(lessons)}", flush=True)
        lesson_type_entry: dict[str, Any] = {
            "type": lesson_type,
            "count": len(lessons),
            "lessons": [],
        }

        for lesson_index, lesson in enumerate(lessons, start=1):
            lesson_id = lesson.get("id")
            if lesson_id is None:
                continue

            print(f"[scrape] lesson {lesson_index}/{len(lessons)} id={lesson_id} title={lesson.get('title')}", flush=True)
            lesson_detail = client.lesson_details(int(lesson_id))
            topic_records = _paginate(lambda page, lid=int(lesson_id): client.topic_page(lid, page))
            topics_out = []

            for topic_index, topic in enumerate(topic_records, start=1):
                topic_id = topic.get("id")
                if topic_id is None:
                    continue

                print(f"[scrape]   topic {topic_index}/{len(topic_records)} id={topic_id} title={topic.get('title')}", flush=True)
                units_payload = client.topic_units(int(lesson_id), int(topic_id))
                unit_records = units_payload.get("data", [])
                units_out = []

                for unit_index, unit in enumerate(unit_records, start=1):
                    unit_id = unit.get("id")
                    if unit_id is None:
                        continue

                    print(f"[scrape]     unit {unit_index}/{len(unit_records)} id={unit_id}", flush=True)
                    questions_payload = client.list_particles(int(lesson_id), int(topic_id), int(unit_id))
                    units_out.append(
                        {
                            "id": unit_id,
                            "title": unit.get("title") or unit.get("name"),
                            "position": unit.get("position"),
                            "type": unit.get("type"),
                            "particles_count": unit.get("particles_count"),
                            "questions": _extract_questions(questions_payload),
                        }
                    )

                topics_out.append(
                    {
                        "id": topic_id,
                        "title": topic.get("title") or topic.get("name"),
                        "position": topic.get("position"),
                        "type": topic.get("type"),
                        "units_available": len(unit_records),
                        "units": units_out,
                    }
                )

            lesson_type_entry["lessons"].append(
                {
                    "id": lesson_id,
                    "title": lesson.get("title") or lesson_detail.get("title"),
                    "position": lesson.get("position"),
                    "grade": lesson.get("grade") or lesson_detail.get("grade"),
                    "videos": lesson_detail.get("videos", []),
                    "static_files": lesson_detail.get("staticFiles", []),
                    "sub_lessons": topics_out,
                }
            )

        export["lesson_types"].append(lesson_type_entry)

    return export


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scrape visible lesson/topic/unit/question data from client.abacusmentalmath.com.")
    parser.add_argument("--username", required=True, help="Student username for the client portal")
    parser.add_argument("--password", required=True, help="Student password for the client portal")
    parser.add_argument("--language-key", default="en", help="Language key required by the login API, default: en")
    parser.add_argument("--lesson-types", nargs="*", default=DEFAULT_LESSON_TYPES, help="Lesson types to export")
    parser.add_argument("--output", default="abacus_client_export.json", help="Where to write the JSON export")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    client = AbacusClient(args.username, args.password, language_key=args.language_key)
    try:
        client.login()
        export = build_export(client, args.lesson_types)
    except Exception as exc:
        print(f"Scrape failed: {exc}", file=sys.stderr)
        return 1

    with open(args.output, "w", encoding="utf-8") as handle:
        json.dump(export, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    total_lessons = sum(item["count"] for item in export["lesson_types"])
    print(f"Wrote {args.output} with {total_lessons} visible lessons.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
