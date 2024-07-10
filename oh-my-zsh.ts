import "npm:zx/globals";
import { $ } from "npm:zx";
import { installPackage } from "./helpers.ts";

const packageManager = argv.pm;
// zsh is already installed and the default shell in macos
if (packageManager === "dnf") {
  await installPackage({ packageName: "zsh", packageManager });
  await $`sudo lchsh $USER`;
}

try {
  await $`ls ~/.oh-my-zsh`;
  console.log(chalk.blue("oh-my-zsh already installed"));
} catch {
  // https://ohmyz.sh/#install
  console.log(
    chalk.green(
      "installing oh-my-zsh, restart the terminal when completed and run `deno task stow`",
    ),
  );
  await $`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`;
}
