export interface EntryOut {
  id: string;
  title: string;
  date: string;
  question_1: string;
  question_2: string;
  tags: string[];
  created_at: string;
  updated_at: string;
}

export interface EntryListItem {
  id: string;
  title: string;
  date: string;
  tags: string[];
  preview: string;
}

export interface EntryCreate {
  question_1: string;
  question_2: string;
}

export interface TagOut {
  id: string;
  name: string;
  color: string;
}

export interface TagsUpdate {
  tags: string[];
}
