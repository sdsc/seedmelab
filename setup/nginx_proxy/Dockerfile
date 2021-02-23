FROM jwilder/nginx-proxy:alpine
  
RUN tmpl_filepath='/app/nginx.tmpl' && \
        src='return 301 https://$host$request_uri' && \
        rev='return 307 https://$host$request_uri' && \
        sed -i -e "s|$src|$rev|g" $tmpl_filepath  

RUN { \
        echo 'client_max_body_size       5G;'; \
        echo 'client_body_buffer_size    128k;'; \
        echo 'proxy_connect_timeout      10m;'; \
        echo 'proxy_send_timeout         10m;'; \
        echo 'proxy_read_timeout         10m;'; \
        echo 'proxy_buffer_size          4k;'; \
        echo 'proxy_buffers              4 32k;'; \
        echo 'proxy_busy_buffers_size    64k;'; \
        echo 'proxy_temp_file_write_size 64k;'; \
    } > /etc/nginx/conf.d/drupal_proxy.conf
