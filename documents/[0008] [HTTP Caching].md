## [HTTP Caching: An Overview](https://www.rfc-editor.org/rfc/rfc9111.html).

HTTP caching is a mechanism used to store copies of resources (like HTML pages, images, scripts, etc.) temporarily so that they can be reused later without having to re-fetch them from the original server. This improves performance by reducing latency and network traffic, which leads to faster page loads for users and less load on servers.

Caching is an essential part of HTTP and is governed by several headers in the HTTP protocol. Here's a detailed breakdown of how HTTP caching works and the key components involved:

### 1. **Cache-Control Header**
The `Cache-Control` header is one of the most important headers for controlling caching behavior. It specifies directives for both requests and responses regarding caching mechanisms. Common directives include:

- **max-age=<seconds>**: Specifies the maximum amount of time (in seconds) that a resource is considered fresh.

  ```http
  Cache-Control: max-age=3600
  ```

- **no-cache**: Forces caches to submit the request to the origin server for validation before releasing a cached copy.

  ```http
  Cache-Control: no-cache
  ```

- **no-store**: Indicates that the response should not be stored in any cache.

  ```http
  Cache-Control: no-store
  ```

- **public**: Indicates that the response may be cached by any cache, even if it would normally be non-cacheable or cacheable only within a private cache.

  ```http
  Cache-Control: public
  ```

- **private**: Indicates that the response is intended for a single user and must not be stored by shared caches (e.g., proxy servers).

  ```http
  Cache-Control: private
  ```

- **must-revalidate**: Tells caches that they must obey any freshness information you give them about a resource.

  ```http
  Cache-Control: must-revalidate
  ```

### 2. **Expires Header**
The `Expires` header defines an absolute expiration time for a cached resource after which the resource is considered stale. If both `Cache-Control: max-age` and `Expires` are present, `Cache-Control` takes precedence.

```http
Expires: Wed, 21 Oct 2023 07:28:00 GMT
```

### 3. **ETag (Entity Tag)**
An `ETag` is an identifier for a specific version of a resource. It allows the client to make conditional requests to check if the resource has changed since it was last fetched. The ETag value is usually a hash of the content.

When a client makes a subsequent request, it can send the `If-None-Match` header with the ETag value:

```http
If-None-Match: "etag-value"
```

If the resource hasn't changed, the server responds with a `304 Not Modified` status code, indicating that the cached version can still be used.

### 4. **Last-Modified and If-Modified-Since**
The `Last-Modified` header indicates the date and time when the resource was last modified. Clients can use this information to make conditional requests using the `If-Modified-Since` header.

Example:
- Server Response:
  ```http
  Last-Modified: Wed, 21 Oct 2023 07:28:00 GMT
  ```

- Client Request:
  ```http
  If-Modified-Since: Wed, 21 Oct 2023 07:28:00 GMT
  ```

If the resource hasn’t been modified since the specified date, the server returns a `304 Not Modified` response.

### 5. **Vary Header**
The `Vary` header is used to specify which parts of the request headers should be taken into account when determining whether a cached response can be used. For example, if a server serves different content based on the `Accept-Encoding` header (e.g., gzip vs. uncompressed), it might include:

```http
Vary: Accept-Encoding
```

This tells the cache to consider the `Accept-Encoding` header when deciding whether to serve a cached response.

### 6. **Pragma Header**
The `Pragma` header is primarily used for backward compatibility with HTTP/1.0 caches. The most common directive is `Pragma: no-cache`, which behaves similarly to `Cache-Control: no-cache`.

```http
Pragma: no-cache
```

However, `Cache-Control` is preferred in HTTP/1.1 and later.

### 7. **Freshness vs. Validation**
- **Freshness**: A resource is considered "fresh" if it’s within its validity period as determined by the `Cache-Control` or `Expires` headers. Fresh resources can be served directly from the cache without contacting the origin server.

- **Validation**: When a resource becomes stale, the cache needs to validate it with the origin server. This is typically done using `ETag` or `Last-Modified` headers.

### 8. **Types of Caches**
There are several types of caches involved in HTTP caching:

- **Browser Cache**: The browser stores resources locally on the user’s device to avoid re-downloading them on subsequent visits.

- **Proxy Cache**: Intermediate proxies or CDNs (Content Delivery Networks) can cache resources to serve them to multiple users, reducing load on the origin server.

- **Gateway Cache**: These are often reverse proxies placed in front of web servers to cache responses and improve performance.

### 9. **Cache Invalidation**
Cache invalidation refers to the process of ensuring that outdated or incorrect data isn’t served from the cache. There are several strategies for cache invalidation:

- **Time-based Expiration**: Resources are automatically invalidated after a certain period (`max-age`, `Expires`).

- **Explicit Invalidation**: The server explicitly marks a resource as stale or sends new headers to invalidate the cache.

- **Versioning**: Changing the URL of a resource (e.g., appending a query string or version number) forces clients to fetch the new version instead of using a cached version.

### Example Workflow

1. **Initial Request**:
    - The client requests a resource.
    - The server responds with the resource along with caching headers like `Cache-Control: max-age=3600` and an `ETag`.

   ```http
   HTTP/1.1 200 OK
   Cache-Control: max-age=3600
   ETag: "abc123"
   Content-Type: text/html
   ```

2. **Subsequent Request**:
    - After some time, the client requests the same resource again.
    - If the resource is still fresh (within the `max-age`), the browser serves it from the cache without contacting the server.

3. **Stale Resource**:
    - If the resource has become stale, the client sends a conditional request with the `If-None-Match` header containing the `ETag`.

   ```http
   GET /resource HTTP/1.1
   Host: example.com
   If-None-Match: "abc123"
   ```

4. **Server Response**:
    - If the resource hasn’t changed, the server responds with `304 Not Modified`, and the client uses the cached version.

   ```http
   HTTP/1.1 304 Not Modified
   ETag: "abc123"
   ```

    - If the resource has changed, the server sends the new version with a new `ETag`.

### Conclusion
HTTP caching is a powerful tool for improving web performance by reducing redundant data transfers and minimizing server load. By leveraging headers such as `Cache-Control`, `ETag`, `Expires`, and others, developers can fine-tune how resources are cached and ensure that users receive up-to-date content efficiently.