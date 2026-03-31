import tensorflow as tf

model_path = '/Users/itmartx/Downloads/models/MobileNetV3Small_autoClasses_final.keras'
model = tf.keras.models.load_model(model_path)
print("Model loaded successfully")
print("Input shape:", model.input_shape)
print("Output shape:", model.output_shape)

converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)

print("Saved model.tflite")
