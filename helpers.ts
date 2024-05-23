import "npm:zx/globals";
import { $ } from "npm:zx";

export async function hasHomebrew() {
  const { stdout: brewInstalledStdout } = await $`command -v brew`;
  if (brewInstalledStdout === "") {
    console.log(chalk.red("hombrew not installed!"));
    return false;
  }
  return true;
}

async function hasHomebrewPackage(packageName: string) {
  try {
    await $`brew ls --versions ${packageName}`;
    return true;
  } catch {
    return false;
  }
}

export async function maybeInstallPackage(packageName: string) {
  if (await hasHomebrewPackage(packageName)) {
    console.log(chalk.blue(`${packageName} already installed`));
    return;
  }

  console.log(chalk.blue(`installing ${packageName}`));
  await spinner(() => $`brew install ${packageName}`);
}
