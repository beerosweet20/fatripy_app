import sys
import subprocess

try:
    import PyPDF2
except ImportError:
    print("PyPDF2 not found, installing...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "PyPDF2"])
    import PyPDF2

try:
    with open('Gp.pdf', 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        text = ""
        for i, page in enumerate(reader.pages):
            text += f"--- Page {i+1} ---\n"
            text += page.extract_text() + "\n"

    with open('Gp_extracted.txt', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Successfully extracted Gp.pdf to Gp_extracted.txt")
except Exception as e:
    print(f"Error reading PDF: {e}")
