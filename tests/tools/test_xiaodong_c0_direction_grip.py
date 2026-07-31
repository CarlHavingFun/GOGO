import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = REPO_ROOT / "tools/xiaodong_c0_direction_grip.py"
SPEC = importlib.util.spec_from_file_location("xiaodong_c0_direction_grip", MODULE_PATH)
if SPEC is None or SPEC.loader is None:
    raise ImportError(f"cannot load {MODULE_PATH}")
module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(module)


def write_layer(path: Path, color: tuple[int, int, int]) -> str:
    path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    for y in range(40, 88):
        for x in range(48, 80):
            image.putpixel((x, y), (*color, 255))
    image.save(path, optimize=False)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_valid_project(root: Path) -> Path:
    body_layers: dict[str, dict[str, dict]] = {}
    grip_groups: dict[str, dict[str, dict]] = {}
    color = module.APPROVED_PALETTE[0]
    for direction in module.DIRECTIONS:
        body_layers[direction] = {}
        for phase in module.PHASES:
            relative = Path(
                f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                f"walk_body/{direction}/body_{direction}_{phase}_cleaned.png"
            )
            digest = write_layer(root / relative, color)
            body_layers[direction][phase] = {
                "path": relative.as_posix(),
                "sha256": digest,
                "root": [64, 114],
            }
        grip_groups[direction] = {}
        for grip in module.GRIPS:
            back = Path(
                f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                f"grips/{grip}/{direction}/{grip}_{direction}_back_arm_cleaned.png"
            )
            front = Path(
                f"assets/source/cleaned/c0/xiaodong/direction_grip/"
                f"grips/{grip}/{direction}/{grip}_{direction}_front_arm_cleaned.png"
            )
            grip_groups[direction][grip] = {
                "back_arm_path": back.as_posix(),
                "back_arm_sha256": write_layer(root / back, color),
                "front_arm_path": front.as_posix(),
                "front_arm_sha256": write_layer(root / front, color),
                "shoulder_pivot": [64, 48],
                "trigger_hand_anchor": [60, 64],
                "support_hand_anchor": [72, 64],
                "weapon_origin": [64, 64],
                "phase_offsets": {
                    "contact_l": [0, 0],
                    "passing_l": [0, -1],
                    "contact_r": [0, 0],
                    "passing_r": [0, -1],
                },
                "occlusion_order": ["back_arm", "body", "weapon", "front_arm"],
            }
    metadata = {
        "schema_version": 1,
        "canvas": {
            "width": 128, "height": 128, "origin": "top_left",
            "x_axis": "right", "y_axis": "down",
        },
        "body_root": [64, 114],
        "direction_order": list(module.DIRECTIONS),
        "c0_phase_order": list(module.PHASES),
        "a5_frame_order": list(module.A5_FRAMES),
        "grip_order": list(module.GRIPS),
        "body_layers": body_layers,
        "grip_groups": grip_groups,
    }
    metadata_path = root / (
        "assets/source/cleaned/c0/xiaodong/"
        "xiaodong_c0_direction_grip_metadata.json"
    )
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return metadata_path


class DirectionGripToolTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.project_root = Path(self.temporary.name)
        self.metadata_path = build_valid_project(self.project_root)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_expected_composite_keys_are_exact(self) -> None:
        keys = module.expected_composite_keys()
        self.assertEqual(len(keys), 96)
        self.assertEqual(len(set(keys)), 96)
        self.assertEqual(keys[0], "xiaodong_c0_walk_n_contact_l_pistol_qa")
        self.assertEqual(keys[-1], "xiaodong_c0_walk_nw_passing_r_sniper_qa")

    def test_valid_metadata_and_layers_pass(self) -> None:
        self.assertEqual(
            module.validate_metadata(self.metadata_path, self.project_root),
            [],
        )

    def test_metadata_rejects_wrong_top_level_keys(self) -> None:
        data = json.loads(self.metadata_path.read_text(encoding="utf-8"))
        data["unexpected"] = True
        self.metadata_path.write_text(json.dumps(data), encoding="utf-8")
        errors = module.validate_metadata(self.metadata_path, self.project_root)
        self.assertTrue(any("top-level keys" in error for error in errors))

    def test_metadata_rejects_offset_hash_and_occlusion_errors(self) -> None:
        data = json.loads(self.metadata_path.read_text(encoding="utf-8"))
        group = data["grip_groups"]["se"]["rifle"]
        group["phase_offsets"]["passing_l"] = [3, 0]
        group["back_arm_sha256"] = "00"
        group["occlusion_order"] = ["body", "back_arm", "front_arm", "front_arm"]
        self.metadata_path.write_text(json.dumps(data), encoding="utf-8")
        errors = module.validate_metadata(self.metadata_path, self.project_root)
        self.assertTrue(any("phase offset" in error for error in errors))
        self.assertTrue(any("SHA-256" in error for error in errors))
        self.assertTrue(any("occlusion_order" in error for error in errors))

    def test_compose_all_writes_exactly_96_rgba_images(self) -> None:
        output_dir = self.project_root / "qa"
        outputs = module.compose_all(self.metadata_path, self.project_root, output_dir)
        self.assertEqual(len(outputs), 96)
        self.assertEqual(len(list(output_dir.glob("*_qa.png"))), 96)
        with Image.open(outputs[0]) as image:
            self.assertEqual(image.mode, "RGBA")
            self.assertEqual(image.size, (128, 128))

    def test_gate_sheet_has_eleven_review_cells(self) -> None:
        sample = next(self.project_root.rglob("*_cleaned.png"))
        cells = {
            "rifle_n": sample, "rifle_ne": sample,
            "rifle_e": sample, "rifle_se": sample,
            "rifle_s": sample, "rifle_sw": sample,
            "rifle_w": sample, "rifle_nw": sample,
            "se_pistol": sample, "se_rifle": sample, "se_sniper": sample,
        }
        output = module.build_gate_sheet(cells, self.project_root / "gate.png")
        with Image.open(output) as image:
            self.assertEqual(image.mode, "RGBA")
            self.assertEqual(image.size, (1024, 768))

    def test_clean_layer_aligns_anchor_and_uses_shared_palette(self) -> None:
        source = Image.new("RGBA", (1254, 1254), (0, 0, 0, 0))
        for y in range(900, 1000):
            for x in range(580, 680):
                source.putpixel((x, y), (250, 210, 175, 255))
        source_path = self.project_root / "source.png"
        preview_path = self.project_root / "preview.png"
        output_path = self.project_root / "cleaned.png"
        source.save(source_path)
        module.clean_layer(
            source_path, preview_path, output_path,
            source_anchor=(512, 816), target_anchor=(512, 912),
        )
        with Image.open(preview_path) as preview:
            self.assertEqual(preview.size, (1024, 1024))
        with Image.open(output_path) as cleaned:
            self.assertEqual(cleaned.mode, "RGBA")
            self.assertEqual(cleaned.size, (128, 128))
            self.assertLessEqual(set(cleaned.getchannel("A").getdata()), {0, 255})

    def test_review_sheet_is_direction_by_phase_grip_matrix(self) -> None:
        sample = next(self.project_root.rglob("*_cleaned.png"))
        composites = {key: sample for key in module.expected_composite_keys()}
        output = module.build_review_sheet(composites, self.project_root / "review.png")
        with Image.open(output) as image:
            self.assertEqual(image.mode, "RGBA")
            self.assertEqual(image.size, (1536, 1024))


if __name__ == "__main__":
    unittest.main()
