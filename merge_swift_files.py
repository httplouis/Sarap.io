import os

# Automatically detect correct root
# This line points to the folder where THIS script is located
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(ROOT_DIR, "_MERGED_src_code.txt")

def collect_swift_files(root_dir):
    swift_files = []
    for root, _, files in os.walk(root_dir):
        for f in files:
            if f.endswith(".swift"):
                full_path = os.path.join(root, f)
                rel_path = os.path.relpath(full_path, root_dir)
                swift_files.append((rel_path, full_path))
    return sorted(swift_files)

def merge_files(files, output_path):
    with open(output_path, "w", encoding="utf-8") as out:
        out.write("📦 MERGED SWIFT SOURCE FILES\n")
        out.write("=" * 80 + "\n\n")
        for rel_path, full_path in files:
            out.write(f"// ===== FILE: {rel_path} =====\n\n")
            with open(full_path, "r", encoding="utf-8") as src:
                out.write(src.read().strip() + "\n\n")
            out.write("// ===== END OF FILE =====\n\n")
            out.write("-" * 80 + "\n\n")
    print(f"✅ Merged {len(files)} files into: {output_path}")

if __name__ == "__main__":
    swift_files = collect_swift_files(ROOT_DIR)
    if not swift_files:
        print("⚠️ No Swift files found under:", ROOT_DIR)
    else:
        merge_files(swift_files, OUTPUT_FILE)
