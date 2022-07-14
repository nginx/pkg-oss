diff --git a/ngx_http_auth_spnego_module.c b/ngx_http_auth_spnego_module.c
index 97c0b44..831da18 100644
--- a/ngx_http_auth_spnego_module.c
+++ b/ngx_http_auth_spnego_module.c
@@ -339,6 +339,7 @@ ngx_http_auth_spnego_headers_basic_only(
     }

     r->headers_out.www_authenticate->hash = 1;
+    r->headers_out.www_authenticate->next = NULL;
     r->headers_out.www_authenticate->key.len = sizeof("WWW-Authenticate") - 1;
     r->headers_out.www_authenticate->key.data = (u_char *) "WWW-Authenticate";
     r->headers_out.www_authenticate->value.len = value.len;
@@ -378,6 +379,7 @@ ngx_http_auth_spnego_headers(
     }

     r->headers_out.www_authenticate->hash = 1;
+    r->headers_out.www_authenticate->next = NULL;
     r->headers_out.www_authenticate->key.len = sizeof("WWW-Authenticate") - 1;
     r->headers_out.www_authenticate->key.data = (u_char *) "WWW-Authenticate";
     r->headers_out.www_authenticate->value.len = value.len;
@@ -399,6 +401,7 @@ ngx_http_auth_spnego_headers(
         }

         r->headers_out.www_authenticate->hash = 2;
+        r->headers_out.www_authenticate->next = NULL;
         r->headers_out.www_authenticate->key.len = sizeof("WWW-Authenticate") - 1;
         r->headers_out.www_authenticate->key.data = (u_char *) "WWW-Authenticate";
         r->headers_out.www_authenticate->value.len = value2.len;
