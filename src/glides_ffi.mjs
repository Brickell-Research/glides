export function halt(code) {
  if (typeof process !== "undefined" && process.exit) {
    process.exit(code);
  } else if (typeof Deno !== "undefined" && Deno.exit) {
    Deno.exit(code);
  }
}
