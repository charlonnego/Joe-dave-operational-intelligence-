export async function onRequest({ request }) {
  const incoming = new URL(request.url);
  const suffix = incoming.pathname.replace(/^\/api(?=\/|$)/, "") || "/";
  const upstream = new URL("https://joe-dave-operations-api.uchechukwuanuforo.workers.dev");
  upstream.pathname = suffix;
  upstream.search = incoming.search;

  const headers = new Headers(request.headers);
  headers.set("Origin", incoming.origin);
  headers.delete("host");

  const init = {
    method: request.method,
    headers,
    redirect: "manual"
  };
  if (request.method !== "GET" && request.method !== "HEAD") {
    init.body = request.body;
  }

  try {
    const response = await fetch(new Request(upstream.toString(), init));
    const responseHeaders = new Headers(response.headers);
    responseHeaders.set("Cache-Control", "no-store");
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: responseHeaders
    });
  } catch {
    return new Response(JSON.stringify({
      error: "The operations API could not be reached through the application gateway.",
      code: "UPSTREAM_UNAVAILABLE"
    }), {
      status: 502,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Cache-Control": "no-store"
      }
    });
  }
}
