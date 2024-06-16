import "npm:zx/globals";
import { $ } from "npm:zx";

async function hasPackage(
  { packageName, packageManager }: {
    packageName: string;
    packageManager: string;
  },
) {
  try {
    if (packageManager === "brew") {
      await $`brew ls --versions ${packageName}`;
    } else {
      await $`dnf list installed ${packageName}`;
    }
    return true;
  } catch {
    return false;
  }
}

export async function installPackage(
  { packageName, packageManager }: {
    packageName: string;
    packageManager: string;
  },
) {
  if (packageManager !== "brew" && packageManager !== "dnf") {
    throw new Error("the --pm argument only supports `brew` or `dnf`");
  }

  if (await hasPackage({ packageName, packageManager })) {
    console.log(chalk.blue(`${packageName} already installed`));
    return;
  }

  if (packageManager === "brew") {
    await $`brew install ${packageName}`;
  } else {
    await $`sudo dnf install ${packageName}`;
  }
}
