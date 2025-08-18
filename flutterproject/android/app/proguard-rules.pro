# Keep all classes in the PyTorch package
-keep class org.pytorch.** { *; }
-keep interface org.pytorch.** { *; }
# Add these new lines for the Facebook JNI dependency
-keep class com.facebook.jni.** { *; }
-keep interface com.facebook.jni.** { *; }