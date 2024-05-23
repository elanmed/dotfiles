import "npm:zx/globals";
import { $ } from "npm:zx";
import { hasHomebrew, maybeInstallPackage } from "./helpers.ts";

const hasBrew = await hasHomebrew();
if (!hasBrew) {
  await $`exit`;
}

await maybeInstallPackage("stow");
const { stdout: dirsStdout } = await $`ls */`;
const cleanDirs = dirsStdout.split("\n").filter(Boolean).map((dir) =>
  dir.substring(0, dir.length - 1)
);

for (const dir of cleanDirs) {
  console.log(chalk.green(`running stow ${dir}`));
  await $`stow ${dir}`;
}
