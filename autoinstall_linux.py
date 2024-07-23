import tkinter as tk
from tkinter import ttk
from tkinter import filedialog
import subprocess
import os

class ShellScriptRunner:
    def __init__(self, root):
        self.root = root
        self.root.title("Executar Script Shell")

        # Adiciona um botão para selecionar o arquivo
        self.select_button = ttk.Button(root, text="Selecionar Arquivo .sh", command=self.select_file)
        self.select_button.pack(pady=10)

        # Adiciona um botão para executar o arquivo
        self.run_button = ttk.Button(root, text="Executar Script", command=self.run_script, state=tk.DISABLED)
        self.run_button.pack(pady=10)

        self.file_path = None

    def select_file(self):
        # Abre uma janela para seleção de arquivo
        self.file_path = filedialog.askopenfilename(filetypes=[("Shell Script", "*.sh")])
        if self.file_path:
            self.run_button.config(state=tk.NORMAL)  # Habilita o botão de execução

    def run_script(self):
        if self.file_path:
            # Adiciona permissões de execução ao arquivo
            os.chmod(self.file_path, 0o755)
            
            # Executa o script
            try:
                subprocess.run([self.file_path], check=True)
                tk.messagebox.showinfo("Sucesso", "Script executado com sucesso!")
            except subprocess.CalledProcessError as e:
                tk.messagebox.showerror("Erro", f"Ocorreu um erro ao executar o script:\n{e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = ShellScriptRunner(root)
    root.mainloop()
