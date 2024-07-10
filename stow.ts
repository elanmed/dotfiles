import "npm:zx/globals";
import { $ } from "npm:zx";
import { installPackage } from "./helpers.ts";

try {
  await $`ls ~/.oh-my-zsh`;
  console.log(chalk.blue("oh-my-zsh already installed, continuing"));
} catch {
  throw new Error(
    "oh-my-zsh is not yet installed, run `deno task oh-my-zsh` before `deno-task-stow`",
  );
}

const confirm = await question(
  chalk.magenta(
    "this will delete your .zshrc, is that ok? `y` for yes, anything else to cancel: ",
  ),
);
if (confirm !== "y") {
  throw new Error("not permitted to delete .zshrc");
}

console.log(chalk.blue("oh-my-zsh installed, removing .zshrc"));
await $`rm -rf ~/.zshrc`;

await installPackage({ packageName: "stow", packageManager: argv.pm });
const { stdout: dirsStdout } = await $`ls -d */`;
const cleanDirs = dirsStdout.split("\n").filter(Boolean).map((dir) =>
  dir.substring(0, dir.length - 1)
);

for (const dir of cleanDirs) {
  console.log(chalk.green(`running stow ${dir}`));
  await $`stow ${dir}`;
}
console.log(
  chalk.green("run `deno task zsh/tmux/neovim` to finish bootstrapping"),
);
