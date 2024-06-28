import "npm:zx/globals";
import { $ } from "npm:zx";

type Code = "M" | "T" | "A" | "D" | "R" | "C" | "?" | " ";
function getMessageFromCode(code: Code) {
  switch (code) {
    case "M": {
      return "modified:     ";
    }
    case "T": {
      return "type changed: ";
    }
    case "A": {
      return "added:        ";
    }
    case "D": {
      return "deleted:      ";
    }
    case "R": {
      return "renamed:      ";
    }
    case "C": {
      return "copied:       ";
    }
    case "?": {
      return "untracked:    ";
    }
    case " ": {
      return "unmodified:   ";
    }
  }
}

const status = await $`git status --short`;
const messageArr = status.stdout.split("\n").filter(Boolean).map((line) => {
  const code = line[0];
  const rest = line.slice(3);
  return `${getMessageFromCode(code as Code)} ${rest}`;
});
const title = "parsed from git status:";
const message = [
  title,
  "=".repeat(title.length),
].concat(messageArr).join("\n");

await $`git commit -m ${message}`;
