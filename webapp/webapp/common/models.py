from django.db import models


class TestModel(models.Model):
    field = models.CharField(default='hello, world!', max_length=255)

    def __str__(self):
        return self.field