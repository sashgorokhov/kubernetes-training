FROM python:2.7

ARG base_dir="/opt/django"

ENV PYTHONUNBUFFERED="1"
CMD python webapp/manage.py runserver 0.0.0.0:80
EXPOSE 80

WORKDIR ${base_dir}

COPY requirements.txt ${base_dir}/requirements.txt
RUN pip install -r requirements.txt

COPY . ${base_dir}

