"""
FigCraft TCP Control Socket Client.
Zero-dependency, pure Python standard library.

Connects to FigCraft's internal control server on port 7979
and sends line-delimited JSON commands over TCP.
"""

import socket
import json
import sys
import os

DEFAULT_PORT = 7979
DEFAULT_HOST = "127.0.0.1"


class FigCraftConnectionError(Exception):
    """Raised when FigCraft control port cannot be reached."""
    pass


def is_running(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT, timeout: float = 1.0) -> bool:
    """Check if FigCraft control server is reachable."""
    try:
        s = socket.create_connection((host, port), timeout=timeout)
        s.close()
        return True
    except (socket.error, OSError):
        return False


def call(method: str, params: dict = None, host: str = DEFAULT_HOST, port: int = DEFAULT_PORT, timeout: float = 60.0) -> dict:
    """
    Send a raw RPC call to FigCraft.
    
    Format:
        {"id": 1, "method": method, "params": params}
    Returns:
        JSON response dict: {"id": 1, "ok": True, "result": {...}}
    """
    try:
        s = socket.create_connection((host, port), timeout=timeout)
    except (socket.error, ConnectionRefusedError, OSError) as e:
        raise FigCraftConnectionError(
            f"Cannot connect to FigCraft on {host}:{port}.\n"
            f"Make sure FigCraft is running with the '--control {port}' flag:\n"
            f"  - Windows: 'C:\\Program Files\\ArtCraft\\FigCraft\\figcraft.exe --control {port}'\n"
            f"  - macOS:   '/Applications/FigCraft.app/Contents/MacOS/FigCraft --control {port}'"
        ) from e

    try:
        payload = json.dumps({"id": 1, "method": method, "params": params or {}}) + "\n"
        s.sendall(payload.encode("utf-8"))
        
        buf = b""
        while b"\n" not in buf:
            chunk = s.recv(65536)
            if not chunk:
                break
            buf += chunk
            
        if not buf:
            raise FigCraftConnectionError("FigCraft closed connection without returning data.")
            
        return json.loads(buf.decode("utf-8").strip())
    finally:
        s.close()


def ex(command: str, host: str = DEFAULT_HOST, port: int = DEFAULT_PORT, **params) -> dict:
    """
    Execute a FigCraft engine command via engine.execute.
    
    Example:
        fc.ex("shape.rectangle", x=0, y=0, width=100, height=50, parent=frame_id)
    """
    return call("engine.execute", {"command": command, "params": params}, host=host, port=port)


def get_commands(filter_keyword: str = None) -> list:
    """List all available FigCraft commands, optionally filtered by keyword."""
    res = call("engine.commands")
    if not res.get("ok"):
        return []
    cmds = res.get("result", [])
    if filter_keyword:
        cmds = [c for c in cmds if filter_keyword.lower() in c.get("id", "").lower()]
    return cmds


if __name__ == "__main__":
    if not is_running():
        print(f"[!] FigCraft control server is NOT running on port {DEFAULT_PORT}.")
        print("Please start FigCraft with '--control 7979' first.")
        sys.exit(1)
        
    print("[+] Successfully connected to FigCraft control server!")
    cmds = get_commands()
    print(f"[+] Total available engine commands: {len(cmds)}")
    if len(sys.argv) > 1:
        keyword = sys.argv[1]
        matches = get_commands(keyword)
        print(f"[+] Commands matching '{keyword}':")
        for m in matches:
            print(f"    - {m.get('id')}: {m.get('params', '')}")
