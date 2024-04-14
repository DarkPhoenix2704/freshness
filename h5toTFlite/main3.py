import tensorflow as tf
# Load the .pb file
converter = tf.lite.TFLiteConverter.from_saved_model("model")
tflite_model = converter.convert()
with open("final_stale.tflite", "wb") as f:
   f.write(tflite_model)