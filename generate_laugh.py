import math
import random

# Generate a simple "haha" laugh sound
sample_rate = 44100
duration = 0.8
num_samples = int(sample_rate * duration)

data = bytearray()

for i in range(num_samples):
    t = i / sample_rate
    
    # Main laugh pitch (low chuckle)
    freq1 = 300 + 50 * math.sin(2 * math.pi * 3 * t)
    wave1 = math.sin(2 * math.pi * freq1 * t)
    
    # Secondary pitch (higher laugh)
    freq2 = 600 + 80 * math.cos(2 * math.pi * 4 * t)
    wave2 = 0.5 * math.sin(2 * math.pi * freq2 * t)
    
    # Pitch modulation for "ha ha" effect
    if t < 0.1 or (0.35 < t < 0.45):
        laugh_tone = 0.7 + 0.3 * math.sin(2 * math.pi * 8 * t)
    else:
        laugh_tone = 1.0
    
    combined = (wave1 + wave2) * laugh_tone
    
    # Add noise for breathy effect
    if t < 0.15 or 0.3 < t < 0.5 or 0.7 < t:
        noise = (random.random() - 0.5) * 0.2
        combined += noise
    
    # Envelope
    if t < 0.05:
        env = 10 * t / 0.05
    elif t > duration - 0.05:
        env = 10 * (duration - t) / 0.05
    else:
        env = 1.0
    
    combined *= env
    
    sample = int(combined * 127.5)
    sample = max(-128, min(127, sample))
    data.append(sample & 0xFF)
    data.append((sample >> 8) & 0xFF)

# Write WAV file manually
with open('assets/sounds/laugh.wav', 'wb') as f:
    # RIFF header
    f.write(b'RIFF')
    f.write((((36 + len(data)) * 4)).to_bytes(4, 'little'))
    f.write(b'WAVE')
    
    fmt_chunk = b'fmt '
    fmt_chunk += 16.to_bytes(4, 'little')
    fmt_chunk += b'\x00\x10'  # Audio format (PCM)
    fmt_chunk += b'\x01\x00'  # Number of channels (1 = mono)
    fmt_chunk += sample_rate.to_bytes(4, 'little')
    byte_rate = sample_rate * 2
    fmt_chunk += byte_rate.to_bytes(4, 'little')
    block_align = 2
    fmt_chunk += block_align.to_bytes(4, 'little')
    bps = 16
    fmt_chunk += bps.to_bytes(4, 'little')
    
    # data chunk
    f.write(b'data')
    f.write(len(data).to_bytes(4, 'little'))
    f.write(bytes(data))

print("Created assets/sounds/laugh.wav")