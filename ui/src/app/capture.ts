export interface Capture {
  id: number;
  title: string;
  reference: string;
  status: 'new' | 'in-progress' | 'complete';
  priority: 'low' | 'normal' | 'high';
}
