import "npm:zx/globals";
import { $ } from "npm:zx";

try {
  await $`ls ~/.oh-my-zsh`;
  await spinner(
    chalk.green("installing zhs-syntax-highlighting"),
    () =>
      $`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`,
  );
  await spinner(
    chalk.green("installing zsh-autosuggestions"),
    () =>
      $`git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`,
  );
} catch {
  throw new Error(
    "oh-my-zsh is not yet installed, run `deno task root` before `deno task zsh`",
  );
}
