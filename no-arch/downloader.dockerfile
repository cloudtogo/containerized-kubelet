# The curlimages/curl is a multi-arch image.
FROM curlimages/curl:7.76.1
USER root
RUN apk update && apk add tar && rm -rf /var/cache/apk/*