docker build -t redis:myredis .

# docker run -v .:/usr/local/etc/redis --rm --name myredis redis redis-server /usr/local/etc/redis/redis.conf