Review recent commit messages to understand the repository's style, check the staged files, and inspect the changes to be committed. If no files are staged, stage all changes.

Decide how to group the changes:

- If the changes are related, create one commit.
- If they affect different areas or unrelated work, create separate commits by staging each logical group in turn.

Write commit messages that:

- Use conventional commit format: `<type>: <description>`
- Use lowercase types, such as `add`, `fix`, `refactor`, `docs`, `tests`, or `misc`
- Use commas to separate multiple changes
- Fit on a single line and stay descriptive but concise

Commit immediately without asking for confirmation. After committing, show the commit message and ask whether the user wants to change it. If they provide a replacement, amend the commit using exactly the text they provide. If they ask another question or change the topic, move on.

When making subsequent changes, don't commit after completing the change; only commit when directly told.
