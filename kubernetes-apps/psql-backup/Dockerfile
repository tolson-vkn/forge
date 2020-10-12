FROM alpine

RUN apk add --no-cache postgresql-client bash

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["backup"]
