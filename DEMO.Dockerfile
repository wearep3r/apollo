# Security Best Practices: https://res.cloudinary.com/snyk/image/upload/v1551798390/Docker_Image_Security_Best_Practices_.pdf
FROM mbiocloud/pybase
# <-- Implement VERSIONING!
LABEL maintainer "micro-biolytics GmbH, Software Development"

# install python packages
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install --trusted-host pypi.python.org -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

######
# Keep this in requirements.txt
# Specify a concrete version that is needed
RUN pip install git+https://gitlab.com/mbio/kombunicator.git
######

# copy source code and change ownership
RUN mkdir /code
COPY --chown=user:user ./src /code

# run application
WORKDIR /code
USER user
# Use ENTRYPOINT with docker-entrypoint.sh
# See here: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python", "run.py"]

# make available to outside world
EXPOSE ${MIRADOCK_PORT}
