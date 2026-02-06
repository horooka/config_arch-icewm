#!/opt/ov/.venv/bin/python
import openvino_genai as ov_genai
import sys
import json
import os

model_path = os.path.expanduser("~/Downloads/qwen_ov/")
pipe = ov_genai.LLMPipeline(model_path, device="GPU")

def main():
    prompt = sys.argv[1] if len(sys.argv) > 1 else "Hello"
    response = pipe.generate(prompt, max_new_tokens=128, temp=0.7)
    print(json.dumps({
        "response": response,
        "context": prompt
    }))

if __name__ == "__main__":
    main()
