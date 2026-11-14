"""Build a release archive and CurseForge upload metadata for a version tag."""

import argparse
import json
import re
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path(__file__).resolve().parents[2]
ALLOWED_SUFFIXES = {'.toc', '.lua', '.xml', '.tga', '.blp', '.png', '.ogg', '.wav'}
FOREVER_GAME_VERSION_TYPE_ID = 88568
FOREVER_GAME_VERSION = '1.60.1'


def get_changelog(version, source_root):
    lines = (source_root / 'CHANGELOG.md').read_text(encoding='utf-8').splitlines()
    heading = re.compile(rf'^## {re.escape(version)}(?:\s|$)')
    start = next((index + 1 for index, line in enumerate(lines) if heading.match(line)), None)
    if start is None:
        raise ValueError(f'Missing changelog section for {version}')

    end = next((index for index in range(start, len(lines)) if lines[index].startswith('## ')), len(lines))
    content = '\n'.join(lines[start:end]).strip()
    if not content:
        raise ValueError(f'Empty changelog section for {version}')
    return content


def get_game_version_id(game_versions_file):
    game_versions = json.loads(game_versions_file.read_text(encoding='utf-8'))
    matches = [
        entry['id']
        for entry in game_versions
        if entry.get('name') == FOREVER_GAME_VERSION
        and entry.get('gameVersionTypeID') == FOREVER_GAME_VERSION_TYPE_ID
    ]
    if len(matches) != 1:
        raise ValueError(f'Expected exactly one CurseForge version for Forever {FOREVER_GAME_VERSION}, found {len(matches)}')
    return matches[0]


def build_release(tag, source_root, game_versions_file, output_dir):
    if not re.fullmatch(r'v\d+\.\d+\.\d+', tag):
        raise ValueError('Tag must be a stable version such as v1.0.2')

    version = tag[1:]
    addon_dir = source_root / 'WritProfession'
    toc_file = addon_dir / 'WritProfession.toc'
    toc = toc_file.read_text(encoding='utf-8-sig')
    if not re.search(rf'^## Version:\s*{re.escape(version)}\s*$', toc, re.MULTILINE):
        raise ValueError(f'Tag {tag} does not match the version in WritProfession.toc')

    files = sorted(
        path for path in addon_dir.rglob('*')
        if path.is_file() and path.suffix.lower() in ALLOWED_SUFFIXES
    )
    if toc_file not in files:
        raise ValueError('WritProfession.toc is missing from the package')

    for line in toc.splitlines():
        entry = line.strip()
        if not entry or entry.startswith('#'):
            continue
        referenced_file = addon_dir / entry.replace('\\', '/')
        if referenced_file not in files:
            raise ValueError(f'TOC references a missing or unsupported file: {entry}')

    output_dir.mkdir(parents=True, exist_ok=True)
    archive = output_dir / f'WritProfession-{version}.zip'
    with ZipFile(archive, 'w', compression=ZIP_DEFLATED, compresslevel=9) as zip_file:
        for file in files:
            zip_file.write(file, file.relative_to(source_root).as_posix())

    metadata = {
        'changelog': get_changelog(version, source_root),
        'changelogType': 'markdown',
        'displayName': f'Writ Profession {version} - WoW Forever',
        'gameVersions': [get_game_version_id(game_versions_file)],
        'releaseType': 'release',
    }
    (output_dir / 'metadata.json').write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
    )
    print(f'Created {archive} containing {len(files)} addon files')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tag', help='Release tag, for example v1.0.2')
    parser.add_argument('--source-root', type=Path, default=ROOT)
    parser.add_argument('--game-versions-file', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'release')
    args = parser.parse_args()
    build_release(args.tag, args.source_root.resolve(), args.game_versions_file, args.output_dir)
