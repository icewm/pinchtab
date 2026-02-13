#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time
import urllib.request

DEFAULT_CONFIG = os.path.expanduser("~/.openclaw/settings/azure-tts.json")
DEFAULT_VOICE = "zh-CN-XiaoxiaoNeural"
DEFAULT_FORMAT = "audio-16khz-32kbitrate-mono-mp3"


def load_config(path: str):
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def synthesize(text: str, endpoint: str, key: str, voice: str, fmt: str, out_path: str):
    # Normalize endpoint
    endpoint = endpoint.rstrip("/")
    if "tts.speech.microsoft.com" not in endpoint:
        # Convert Cognitive Services endpoint to TTS endpoint
        # Example: https://eastus.api.cognitive.microsoft.com -> https://eastus.tts.speech.microsoft.com
        if endpoint.startswith("https://"):
            host = endpoint[len("https://"):]
            region = host.split(".")[0]
            endpoint = f"https://{region}.tts.speech.microsoft.com"
        elif endpoint.startswith("http://"):
            host = endpoint[len("http://"):]
            region = host.split(".")[0]
            endpoint = f"https://{region}.tts.speech.microsoft.com"
    url = f"{endpoint}/cognitiveservices/v1"

    ssml = (
        f"<speak version='1.0' xml:lang='zh-CN'>"
        f"<voice name='{voice}'>"
        f"{text}"
        f"</voice>"
        f"</speak>"
    ).encode("utf-8")

    req = urllib.request.Request(url, data=ssml, method="POST")
    req.add_header("Ocp-Apim-Subscription-Key", key)
    req.add_header("Content-Type", "application/ssml+xml")
    req.add_header("X-Microsoft-OutputFormat", fmt)
    req.add_header("User-Agent", "openclaw-azure-tts")

    with urllib.request.urlopen(req) as resp:
        audio = resp.read()

    with open(out_path, "wb") as f:
        f.write(audio)


def main():
    p = argparse.ArgumentParser(description="Azure TTS quick synth")
    p.add_argument("text", help="text to synthesize")
    p.add_argument("-c", "--config", default=DEFAULT_CONFIG, help="config path")
    p.add_argument("-e", "--endpoint", help="endpoint base URL")
    p.add_argument("-k", "--key", help="subscription key")
    p.add_argument("-v", "--voice", default=DEFAULT_VOICE, help="voice name")
    p.add_argument("-f", "--format", default=DEFAULT_FORMAT, help="output format")
    p.add_argument("-o", "--out", help="output file")
    args = p.parse_args()

    cfg = load_config(args.config)
    endpoint = args.endpoint or cfg.get("endpoint")
    key = args.key or cfg.get("key")
    voice = args.voice or cfg.get("voice", DEFAULT_VOICE)
    fmt = args.format or cfg.get("format", DEFAULT_FORMAT)

    if not endpoint or not key:
        print("Missing endpoint or key. Provide via args or config.", file=sys.stderr)
        sys.exit(2)

    out_path = args.out or os.path.join("/tmp", f"azure-tts-{int(time.time())}.mp3")
    synthesize(args.text, endpoint, key, voice, fmt, out_path)
    print(out_path)


if __name__ == "__main__":
    main()
