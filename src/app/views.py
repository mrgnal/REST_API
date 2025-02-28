from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action, api_view
from .models import Course, Student, Grade
from .serializers import CourseSerializer, StudentSerializer, GradeSerializer, StudentDetailSerializer, GradeDetailSerializer

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    @action(detail=False, methods=['get'], url_path="search")
    def search(self, request):
        teacher = request.query_params.get('teacher')
        name = request.query_params.get('name')
        queryset = Course.objects.all()

        if teacher:
            queryset = queryset.filter(teacher__icontains=teacher)
        if name:
            queryset = queryset.filter(name__icontains=name)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer

    @action(detail=True, methods=['get'])
    def courses(self, request, pk=None):
        student = self.get_object()
        serializer = StudentDetailSerializer(student)
        return Response(serializer.data)


class GradeViewSet(viewsets.ModelViewSet):
    queryset = Grade.objects.all()
    serializer_class = GradeSerializer

    @action(detail=True, methods=['get'], url_path="student_grades")
    def student_grades(self, request, pk=None):
        grade = self.get_object()
        serializer = GradeDetailSerializer(grade)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path="report")
    def report(self, request):
        grades = Grade.objects.all()
        serializer = GradeDetailSerializer(grades, many=True)
        return Response(serializer.data)

@api_view(['GET'])
def hello_world(request):
    return Response({"message": "Hello, World!"})