import type { EntryCreate, EntryListItem, EntryOut, TagOut } from "../types";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const API_KEY = import.meta.env.VITE_API_KEY || "";

export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }

  get isUnauthorized() {
    return this.status === 401;
  }
}

export function getErrorKey(err: unknown): string {
  if (err instanceof ApiError && err.isUnauthorized) {
    return "error_unauthorized";
  }
  if (err instanceof TypeError) {
    return "error_network";
  }
  return "error_generic";
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers: HeadersInit = {
    "Content-Type": "application/json",
    ...(API_KEY && { "X-API-Key": API_KEY }),
    ...options.headers,
  };

  const res = await fetch(`${API_URL}${path}`, { ...options, headers });
  if (!res.ok) {
    throw new ApiError(res.status, `API error: ${res.status}`);
  }
  return res.json();
}

export const api = {
  listEntries: () => request<EntryListItem[]>("/entries"),
  getEntry: (id: string) => request<EntryOut>(`/entries/${id}`),
  createEntry: (data: EntryCreate) =>
    request<EntryOut>("/entries", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  updateTags: (id: string, tags: string[]) =>
    request<EntryOut>(`/entries/${id}/tags`, {
      method: "PATCH",
      body: JSON.stringify({ tags }),
    }),
  listTags: () => request<TagOut[]>("/tags"),
};
