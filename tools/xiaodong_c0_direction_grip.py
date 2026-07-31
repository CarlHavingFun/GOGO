from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw

DIRECTIONS = ("n", "ne", "e", "se", "s", "sw", "w", "nw")
PHASES = ("contact_l", "passing_l", "contact_r", "passing_r")
A5_FRAMES = (
    "contact_l", "down_l", "passing_l", "up_l",
    "contact_r", "down_r", "passing_r", "up_r",
)
GRIPS = ("pistol", "rifle", "sniper")
TOP_LEVEL_KEYS = {
    "schema_version", "canvas", "body_root", "direction_order",
    "c0_phase_order", "a5_frame_order", "grip_order",
    "body_layers", "grip_groups",
}
BODY_RECORD_KEYS = {"path", "sha256", "root"}
GRIP_RECORD_KEYS = {
    "back_arm_path", "back_arm_sha256",
    "front_arm_path", "front_arm_sha256",
    "shoulder_pivot", "trigger_hand_anchor",
    "support_hand_anchor", "weapon_origin",
    "phase_offsets", "occlusion_order",
}
OCCLUSION_TOKENS = {"body", "back_arm", "weapon", "front_arm"}
APPROVED_PALETTE = (
    (0xfd, 0xd3, 0xb2), (0xfd, 0xcd, 0xab), (0xf8, 0xb7, 0x8e),
    (0xe6, 0x8b, 0x59), (0xc9, 0x6b, 0x3d), (0xb3, 0x55, 0x2e),
    (0x9b, 0x4b, 0x27), (0x7a, 0x44, 0x2e), (0x80, 0x35, 0x1c),
    (0x64, 0x2b, 0x17), (0x3d, 0x31, 0x35), (0x3b, 0x2b, 0x2e),
    (0x35, 0x2b, 0x2f), (0x33, 0x29, 0x2d), (0x30, 0x26, 0x2b),
    (0x2a, 0x23, 0x26), (0x4e, 0x18, 0x0b), (0x30, 0x14, 0x0f),
    (0x26, 0x20, 0x23), (0x26, 0x18, 0x1a), (0x21, 0x1c, 0x1e),
    (0x20, 0x18, 0x1c), (0x1d, 0x16, 0x1a), (0x1d, 0x0e, 0x0e),
    (0x16, 0x12, 0x13), (0x12, 0x0e, 0x0f), (0x10, 0x0b, 0x0d),
    (0x09, 0x09, 0x06), (0x0e, 0x04, 0x05), (0x06, 0x03, 0x04),
    (0x02, 0x03, 0x01), (0x01, 0x00, 0x00),
)
APPROVED_PALETTE_SET = set(APPROVED_PALETTE)


def load_metadata(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("metadata root must be an object")
    return value


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_composite_keys() -> tuple[str, ...]:
    return tuple(
        f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
        for direction in DIRECTIONS
        for phase in PHASES
        for grip in GRIPS
    )


def is_int_pair(
    value: object,
    minimum: int | None = None,
    maximum: int | None = None,
) -> bool:
    if not isinstance(value, list) or len(value) != 2:
        return False
    if any(type(component) is not int for component in value):
        return False
    if minimum is not None and any(component < minimum for component in value):
        return False
    if maximum is not None and any(component > maximum for component in value):
        return False
    return True


def inspect_layer(
    path: Path,
    palette: set[tuple[int, int, int]],
) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"{path}: missing layer"]
    with Image.open(path) as image:
        if image.mode != "RGBA":
            errors.append(f"{path}: mode must be RGBA")
        if image.size != (128, 128):
            errors.append(f"{path}: size must be 128x128")
        rgba = image.convert("RGBA")
        alpha_values = set(rgba.getchannel("A").getdata())
        if not alpha_values <= {0, 255}:
            errors.append(f"{path}: alpha must be binary")
        corners = ((0, 0), (127, 0), (0, 127), (127, 127))
        if any(rgba.getpixel(point)[3] != 0 for point in corners):
            errors.append(f"{path}: all corners must be transparent")
        visible = {pixel[:3] for pixel in rgba.getdata() if pixel[3]}
        if any(g > 240 and r < 32 and b < 32 for r, g, b in visible):
            errors.append(f"{path}: strong green residue is forbidden")
        if not visible <= palette:
            errors.append(f"{path}: visible colors exceed the approved shared palette")
    return errors


def project_file(project_root: Path, value: object) -> Path | None:
    if not isinstance(value, str) or not value:
        return None
    relative = Path(value)
    if relative.is_absolute() or ".." in relative.parts:
        return None
    root = project_root.resolve()
    resolved = (root / relative).resolve()
    if resolved != root and root not in resolved.parents:
        return None
    return resolved


def validate_metadata(
    path: Path,
    project_root: Path,
    palette: set[tuple[int, int, int]] = APPROVED_PALETTE_SET,
) -> list[str]:
    errors: list[str] = []
    try:
        data = load_metadata(path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"metadata load failed: {error}"]
    if set(data) != TOP_LEVEL_KEYS:
        errors.append("metadata top-level keys must match the exact schema")
    if data.get("schema_version") != 1:
        errors.append("schema_version must be integer 1")
    expected_canvas = {
        "width": 128, "height": 128, "origin": "top_left",
        "x_axis": "right", "y_axis": "down",
    }
    if data.get("canvas") != expected_canvas:
        errors.append(
            "canvas must match the exact 128x128 top-left screen-coordinate contract"
        )
    if data.get("body_root") != [64, 114]:
        errors.append("body_root must equal [64, 114]")
    for field, expected in (
        ("direction_order", list(DIRECTIONS)),
        ("c0_phase_order", list(PHASES)),
        ("a5_frame_order", list(A5_FRAMES)),
        ("grip_order", list(GRIPS)),
    ):
        if data.get(field) != expected:
            errors.append(f"{field} differs from the fixed order")

    body_layers = data.get("body_layers")
    if not isinstance(body_layers, dict) or set(body_layers) != set(DIRECTIONS):
        errors.append("body_layers must contain the exact eight directions")
        body_layers = {}
    for direction in DIRECTIONS:
        phases = body_layers.get(direction)
        if not isinstance(phases, dict) or set(phases) != set(PHASES):
            errors.append(
                f"body_layers.{direction} must contain the exact four phases"
            )
            continue
        for phase in PHASES:
            record = phases[phase]
            label = f"body_layers.{direction}.{phase}"
            if not isinstance(record, dict) or set(record) != BODY_RECORD_KEYS:
                errors.append(f"{label} must use the exact body record keys")
                continue
            if record.get("root") != [64, 114]:
                errors.append(f"{label} root must equal [64, 114]")
            layer_path = project_file(project_root, record.get("path"))
            if layer_path is None:
                errors.append(f"{label} path must be safe and project-relative")
                continue
            if not layer_path.is_file():
                errors.append(f"{label} layer is missing")
                continue
            if record.get("sha256") != sha256(layer_path):
                errors.append(f"{label} SHA-256 differs from file bytes")
            errors.extend(inspect_layer(layer_path, palette))

    grip_groups = data.get("grip_groups")
    if not isinstance(grip_groups, dict) or set(grip_groups) != set(DIRECTIONS):
        errors.append("grip_groups must contain the exact eight directions")
        grip_groups = {}
    for direction in DIRECTIONS:
        groups = grip_groups.get(direction)
        if not isinstance(groups, dict) or set(groups) != set(GRIPS):
            errors.append(f"grip_groups.{direction} must contain pistol/rifle/sniper")
            continue
        for grip in GRIPS:
            record = groups[grip]
            label = f"grip_groups.{direction}.{grip}"
            if not isinstance(record, dict) or set(record) != GRIP_RECORD_KEYS:
                errors.append(f"{label} must use the exact grip record keys")
                continue
            for path_field, digest_field in (
                ("back_arm_path", "back_arm_sha256"),
                ("front_arm_path", "front_arm_sha256"),
            ):
                layer_path = project_file(project_root, record.get(path_field))
                if layer_path is None:
                    errors.append(
                        f"{label}.{path_field} must be safe and project-relative"
                    )
                    continue
                if not layer_path.is_file():
                    errors.append(f"{label}.{path_field} is missing")
                    continue
                if record.get(digest_field) != sha256(layer_path):
                    errors.append(
                        f"{label}.{digest_field} SHA-256 differs from file bytes"
                    )
                errors.extend(inspect_layer(layer_path, palette))
            for anchor_field in (
                "shoulder_pivot", "trigger_hand_anchor",
                "support_hand_anchor", "weapon_origin",
            ):
                if not is_int_pair(record.get(anchor_field), 0, 127):
                    errors.append(
                        f"{label}.{anchor_field} must be an integer pair in 0..127"
                    )
            offsets = record.get("phase_offsets")
            if not isinstance(offsets, dict) or set(offsets) != set(PHASES):
                errors.append(
                    f"{label}.phase_offsets must contain the exact four phases"
                )
            else:
                if offsets.get("contact_l") != [0, 0]:
                    errors.append(
                        f"{label} contact_l phase offset must equal [0, 0]"
                    )
                for phase in PHASES:
                    if not is_int_pair(offsets.get(phase), -2, 2):
                        errors.append(
                            f"{label}.{phase} phase offset must be integer -2..2"
                        )
            order = record.get("occlusion_order")
            if (
                not isinstance(order, list)
                or len(order) != 4
                or set(order) != OCCLUSION_TOKENS
            ):
                errors.append(
                    f"{label}.occlusion_order must contain each token once"
                )
    return errors


def nearest_palette_color(
    rgb: tuple[int, int, int],
) -> tuple[int, int, int]:
    return min(
        APPROVED_PALETTE,
        key=lambda color: sum(
            (rgb[index] - color[index]) ** 2 for index in range(3)
        ),
    )


def retain_largest_eight_connected_component(
    image: Image.Image,
) -> Image.Image:
    rgba = image.convert("RGBA")
    visible = {
        (x, y)
        for y in range(rgba.height)
        for x in range(rgba.width)
        if rgba.getpixel((x, y))[3] > 0
    }
    components: list[set[tuple[int, int]]] = []
    while visible:
        seed = visible.pop()
        component = {seed}
        stack = [seed]
        while stack:
            x, y = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if dx == 0 and dy == 0:
                        continue
                    neighbor = (x + dx, y + dy)
                    if neighbor in visible:
                        visible.remove(neighbor)
                        component.add(neighbor)
                        stack.append(neighbor)
        components.append(component)
    keep = max(components, key=len) if components else set()
    result = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    for point in keep:
        result.putpixel(point, rgba.getpixel(point))
    return result


def clean_layer(
    input_path: Path,
    preview_path: Path,
    output_path: Path,
    source_anchor: tuple[int, int],
    target_anchor: tuple[int, int],
) -> Path:
    with Image.open(input_path) as source:
        normalized = source.convert("RGBA").resize(
            (1024, 1024),
            Image.Resampling.NEAREST,
        )
    dx = target_anchor[0] - source_anchor[0]
    dy = target_anchor[1] - source_anchor[1]
    preview = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    preview.alpha_composite(normalized, dest=(dx, dy))
    preview_path.parent.mkdir(parents=True, exist_ok=True)
    preview.save(preview_path, optimize=False)
    logical = preview.resize((128, 128), Image.Resampling.NEAREST)
    pixels = []
    for red, green, blue, alpha in logical.getdata():
        if alpha < 128:
            pixels.append((0, 0, 0, 0))
        else:
            mapped = nearest_palette_color((red, green, blue))
            pixels.append((*mapped, 255))
    logical.putdata(pixels)
    logical = retain_largest_eight_connected_component(logical)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    logical.save(output_path, optimize=False)
    return output_path


def shifted(layer: Image.Image, offset: list[int]) -> Image.Image:
    result = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    result.alpha_composite(layer, dest=(offset[0], offset[1]))
    return result


def compose_one(
    body_path: Path,
    back_arm_path: Path,
    front_arm_path: Path,
    offset: list[int],
    occlusion_order: list[str],
    output_path: Path,
) -> Path:
    with Image.open(body_path) as body_image, \
         Image.open(back_arm_path) as back_image, \
         Image.open(front_arm_path) as front_image:
        layers = {
            "body": body_image.convert("RGBA"),
            "back_arm": shifted(back_image.convert("RGBA"), offset),
            "front_arm": shifted(front_image.convert("RGBA"), offset),
        }
        canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
        for token in occlusion_order:
            if token == "weapon":
                continue
            canvas.alpha_composite(layers[token])
        output_path.parent.mkdir(parents=True, exist_ok=True)
        canvas.save(output_path, optimize=False)
    return output_path


def compose_all(
    metadata_path: Path,
    project_root: Path,
    output_dir: Path,
) -> list[Path]:
    errors = validate_metadata(metadata_path, project_root)
    if errors:
        raise ValueError("\n".join(errors))
    data = load_metadata(metadata_path)
    outputs: list[Path] = []
    for direction in DIRECTIONS:
        for phase in PHASES:
            body = data["body_layers"][direction][phase]
            for grip in GRIPS:
                group = data["grip_groups"][direction][grip]
                key = f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
                output = output_dir / f"{key}.png"
                compose_one(
                    project_file(project_root, body["path"]),
                    project_file(project_root, group["back_arm_path"]),
                    project_file(project_root, group["front_arm_path"]),
                    group["phase_offsets"][phase],
                    group["occlusion_order"],
                    output,
                )
                outputs.append(output)
    if tuple(path.stem for path in outputs) != expected_composite_keys():
        raise ValueError("composite output order differs from the fixed contract")
    return outputs


GATE_LAYOUT = (
    ("rifle_n", "rifle_ne", "rifle_e", "rifle_se"),
    ("rifle_s", "rifle_sw", "rifle_w", "rifle_nw"),
    ("se_pistol", "se_rifle", "se_sniper", "legend"),
)


def build_gate_sheet(cells: dict[str, Path], output_path: Path) -> Path:
    required = {key for row in GATE_LAYOUT for key in row if key != "legend"}
    if set(cells) != required:
        raise ValueError(f"gate cells must equal {sorted(required)}")
    sheet = Image.new("RGBA", (1024, 768), (26, 26, 30, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    for row_index, row in enumerate(GATE_LAYOUT):
        for column_index, key in enumerate(row):
            x = column_index * 256
            y = row_index * 256
            if key == "legend":
                draw.multiline_text(
                    (x + 12, y + 20),
                    "Eight directions: head + torso + hips + feet\n"
                    "SE comparison: pistol / rifle / sniper\n"
                    "Empty hands only; weapon node omitted",
                    fill=(255, 255, 255, 255),
                    spacing=8,
                )
                continue
            with Image.open(cells[key]) as image:
                cell = image.convert("RGBA").resize(
                    (256, 256),
                    Image.Resampling.NEAREST,
                )
            sheet.alpha_composite(cell, dest=(x, y))
            draw.rectangle((x, y, x + 150, y + 18), fill=(0, 0, 0, 210))
            draw.text((x + 4, y + 3), key, fill=(255, 255, 255, 255))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path, optimize=False)
    return output_path


def build_review_sheet(
    composites: dict[str, Path],
    output_path: Path,
) -> Path:
    if set(composites) != set(expected_composite_keys()):
        raise ValueError("review sheet requires the exact 96 composite keys")
    sheet = Image.new("RGBA", (1536, 1024), (26, 26, 30, 255))
    draw = ImageDraw.Draw(sheet, "RGBA")
    for row, direction in enumerate(DIRECTIONS):
        for phase_index, phase in enumerate(PHASES):
            for grip_index, grip in enumerate(GRIPS):
                column = phase_index * len(GRIPS) + grip_index
                key = f"xiaodong_c0_walk_{direction}_{phase}_{grip}_qa"
                with Image.open(composites[key]) as image:
                    cell = image.convert("RGBA")
                x = column * 128
                y = row * 128
                sheet.alpha_composite(cell, dest=(x, y))
                draw.rectangle((x, y, x + 126, y + 12), fill=(0, 0, 0, 180))
                draw.text(
                    (x + 2, y + 1),
                    f"{direction} {phase} {grip}",
                    fill=(255, 255, 255, 255),
                )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path, optimize=False)
    return output_path


def parse_anchor(value: str) -> tuple[int, int]:
    parts = value.split(",")
    if len(parts) != 2 or not all(
        part.strip().lstrip("-").isdigit() for part in parts
    ):
        raise argparse.ArgumentTypeError("anchor must be X,Y integers")
    return int(parts[0]), int(parts[1])


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)

    validate_parser = commands.add_parser("validate")
    validate_parser.add_argument("--metadata", type=Path, required=True)
    validate_parser.add_argument("--project-root", type=Path, required=True)

    clean_parser = commands.add_parser("clean-layer")
    clean_parser.add_argument("--input", type=Path, required=True)
    clean_parser.add_argument("--preview", type=Path, required=True)
    clean_parser.add_argument("--output", type=Path, required=True)
    clean_parser.add_argument("--source-anchor", type=parse_anchor, required=True)
    clean_parser.add_argument("--target-anchor", type=parse_anchor, required=True)

    compose_parser = commands.add_parser("compose-all")
    compose_parser.add_argument("--metadata", type=Path, required=True)
    compose_parser.add_argument("--project-root", type=Path, required=True)
    compose_parser.add_argument("--output-dir", type=Path, required=True)

    gate_parser = commands.add_parser("gate-sheet")
    gate_parser.add_argument("--cells-json", type=Path, required=True)
    gate_parser.add_argument("--output", type=Path, required=True)
    gate_parser.add_argument("--project-root", type=Path, default=Path("."))

    review_parser = commands.add_parser("review-sheet")
    review_parser.add_argument("--input-dir", type=Path, required=True)
    review_parser.add_argument("--output", type=Path, required=True)

    arguments = parser.parse_args(argv)
    try:
        if arguments.command == "validate":
            errors = validate_metadata(arguments.metadata, arguments.project_root)
            if errors:
                print("\n".join(errors), file=sys.stderr)
                return 1
            print("C0_DIRECTION_GRIP_QA=PASS")
        elif arguments.command == "clean-layer":
            clean_layer(
                arguments.input, arguments.preview, arguments.output,
                arguments.source_anchor, arguments.target_anchor,
            )
            print(arguments.output.as_posix())
        elif arguments.command == "compose-all":
            outputs = compose_all(
                arguments.metadata,
                arguments.project_root,
                arguments.output_dir,
            )
            print(f"COMPOSITE_COUNT={len(outputs)}")
        elif arguments.command == "gate-sheet":
            raw = json.loads(arguments.cells_json.read_text(encoding="utf-8"))
            cells = {
                key: project_file(arguments.project_root, value)
                for key, value in raw.items()
            }
            if any(path is None for path in cells.values()):
                raise ValueError("gate cell path must be safe and project-relative")
            output = build_gate_sheet(cells, arguments.output)
            print(f"GATE_SHEET={output.as_posix()}")
            print(f"GATE_SHEET_SHA256={sha256(output)}")
        elif arguments.command == "review-sheet":
            composites = {
                key: arguments.input_dir / f"{key}.png"
                for key in expected_composite_keys()
            }
            output = build_review_sheet(composites, arguments.output)
            print(f"REVIEW_SHEET={output.as_posix()}")
            print(f"REVIEW_SHEET_SHA256={sha256(output)}")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
