CREATE TABLE IF NOT EXISTS visits (
    id BIGSERIAL PRIMARY KEY,
    date DATE UNIQUE NOT NULL,
    count INTEGER DEFAULT 0,
    unique_visitors TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_visits_date ON visits(date);

ALTER TABLE visits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous read access" ON visits
    FOR SELECT
    TO anon, authenticated
    USING (true);

CREATE POLICY "Allow anonymous insert access" ON visits
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

CREATE POLICY "Allow anonymous update access" ON visits
    FOR UPDATE
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_visits_updated_at 
    BEFORE UPDATE ON visits 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

INSERT INTO visits (date, count, unique_visitors)
VALUES (CURRENT_DATE, 0, '{}')
ON CONFLICT (date) DO NOTHING;
