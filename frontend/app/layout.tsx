import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Stand Capacity Planner',
  description: 'Plan and manage stand capacity efficiently',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
