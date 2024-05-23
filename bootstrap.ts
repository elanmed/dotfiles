import "npm:zx/globals";
import { $ } from "npm:zx";

async function hasHomebrew() {
  const { stdout: brewInstalledStdout } = await $`command -v brew`;
  if (brewInstalledStdout === "") {
    console.log(chalk.red("hombrew not installed!"));
    return false;
  }
  return true;
}

async function hasHomebrewPackage(packageName: string) {
  const { stdout } = await $`brew ls --versions ${packageName}`;
  return stdout !== "";
}

async function maybeInstallPackage(packageName: string) {
  if (await hasHomebrewPackage(packageName)) {
    console.log(chalk.green(`${packageName} already installed`));
    return;
  }

  await $`brew install ${packageName}`;
}

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
  console.log(chalk.green(`running: stow ${dir}`));
  await $`stow ${dir}`;
}
