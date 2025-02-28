from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CourseViewSet, StudentViewSet, GradeViewSet, hello_world

router = DefaultRouter()
router.register(r'courses', CourseViewSet)
router.register(r'students', StudentViewSet)
router.register(r'grades', GradeViewSet)

urlpatterns = [
    path('hello/', hello_world),
    path('', include(router.urls)),
]
