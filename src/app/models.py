from django.db import models

# Create your models here.
class Course(models.Model):
    name = models.CharField(max_length=255)
    teacher = models.CharField(max_length=255)
    duration = models.PositiveIntegerField(help_text="Тривалість у днях")
    start_date = models.DateField()

    def __str__(self):
        return self.name

class Student(models.Model):
    name = models.CharField(max_length=255)
    surname = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    courses = models.ManyToManyField(Course, related_name="students", blank=True)

    def __str__(self):
        return self.surname + " " + self.name

class Grade(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name="grades")
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="grades")
    score = models.DecimalField(max_digits=5, decimal_places=2)
    date = models.DateField(auto_now_add=True)

    class Meta:
        unique_together = ('student', 'course')

    def __str__(self):
        return f"{self.student.surname} - {self.course.name}: {self.score}"