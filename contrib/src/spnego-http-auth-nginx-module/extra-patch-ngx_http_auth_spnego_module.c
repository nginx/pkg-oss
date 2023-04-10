diff --git a/ngx_http_auth_spnego_module.c b/ngx_http_auth_spnego_module.c
index 97c0b44..831da18 100644
--- a/ngx_http_auth_spnego_module.c
+++ b/ngx_http_auth_spnego_module.c
@@ -505,10 +505,11 @@
     if (NULL == r->headers_out.www_authenticate) {
         return NGX_ERROR;
     }

     r->headers_out.www_authenticate->hash = 1;
+    r->headers_out.www_authenticate->next = NULL;
     r->headers_out.www_authenticate->key.len = sizeof("WWW-Authenticate") - 1;
     r->headers_out.www_authenticate->key.data = (u_char *)"WWW-Authenticate";
     r->headers_out.www_authenticate->value.len = value.len;
     r->headers_out.www_authenticate->value.data = value.data;

@@ -541,10 +542,11 @@
     if (NULL == r->headers_out.www_authenticate) {
         return NGX_ERROR;
     }

     r->headers_out.www_authenticate->hash = 1;
+    r->headers_out.www_authenticate->next = NULL;
     r->headers_out.www_authenticate->key.len = sizeof("WWW-Authenticate") - 1;
     r->headers_out.www_authenticate->key.data = (u_char *)"WWW-Authenticate";
     r->headers_out.www_authenticate->value.len = value.len;
     r->headers_out.www_authenticate->value.data = value.data;

@@ -562,10 +564,11 @@
         if (NULL == r->headers_out.www_authenticate) {
             return NGX_ERROR;
         }

         r->headers_out.www_authenticate->hash = 2;
+        r->headers_out.www_authenticate->next = NULL;
         r->headers_out.www_authenticate->key.len =
             sizeof("WWW-Authenticate") - 1;
         r->headers_out.www_authenticate->key.data =
             (u_char *)"WWW-Authenticate";
         r->headers_out.www_authenticate->value.len = value2.len;
@@ -754,11 +757,11 @@

 static ngx_int_t
 ngx_http_auth_spnego_store_delegated_creds(ngx_http_request_t *r,
                                            ngx_str_t *principal_name,
                                            creds_info delegated_creds) {
-    krb5_context kcontext;
+    krb5_context kcontext = NULL;
     krb5_principal principal = NULL;
     krb5_ccache ccache = NULL;
     krb5_error_code kerr = 0;
     char *ccname = NULL;
     char *escaped = NULL;
