import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const command =
  "cargo fmt && cargo clippy --fix --allow-dirty -- -D warnings";

export default function (pi: ExtensionAPI) {
  // Serialize hook commands when multiple edit/write results overlap.
  let queue: Promise<void> = Promise.resolve();

  pi.on("tool_result", (event, ctx) => {
    if (
      event.isError ||
      (event.toolName !== "edit" && event.toolName !== "write")
    ) {
      return;
    }

    const run = queue.then(async () => {
      let failed = false;
      let report: string;

      try {
        const result = await pi.exec("bash", ["-c", command], {
          cwd: ctx.cwd,
          signal: ctx.signal,
          timeout: 300_000,
        });

        failed = result.code !== 0 || result.killed;

        const output = [result.stdout, result.stderr]
          .filter(Boolean)
          .join("\n");

        report = [
          `$ ${command}`,
          `Exit code: ${result.code}${result.killed ? " (terminated)" : ""}`,
          output || "(no output)",
        ].join("\n");
      } catch (error) {
        failed = true;
        report = `Rust hook failed: ${String(error)}`;
      }

      return {
        content: [
          ...event.content,
          {
            type: "text" as const,
            text:
              "\nRust post-edit checks:\n" +
              report.slice(-16_000) +
              (failed
                ? "\nThe file change was applied, but post-edit checks failed."
                : "\nFormatting and automatic fixes may have changed files."),
          },
        ],
        isError: failed,
      };
    });

    // Keep later checks runnable even if a previous handler rejects.
    queue = run.then(
      () => undefined,
      () => undefined,
    );

    return run;
  });
}
