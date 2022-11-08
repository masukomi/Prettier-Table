#!/usr/bin/env raku

# A simple example of Prettier::Table usage.

use Prettier::Table;

sub add-australian-city-data($table) {
    given $table {
        .add-row: ["Adelaide",  1295,  1158259,  600.5 ];
        .add-row: ["Brisbane",  5905,  1857594,  1146.4];
        .add-row: ["Darwin",    112,   120900,   1714.7];
        .add-row: ["Hobart",    1357,  205556,   619.5 ];
        .add-row: ["Sydney",    2058,  4336374,  1214.8];
        .add-row: ["Melbourne", 1566,  3806092,  646.9 ];
        .add-row: ["Perth",     5386,  1554769,  869.4 ];
    }
}

my $table = Prettier::Table.new:
    title => "Australian Cities",
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    sort-by => 'Area',
    align => %('City name' => 'l'),
;
add-australian-city-data($table);

say $table;

$table = Prettier::Table.new;

given $table {
    .add-column('Planet', ['Earth', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune']);
    .add-column('Position', [3, 1, 2, 4, 5, 6, 7, 8])
    .add-column('Known Satellites', [1, 0, 0, 2, 79, 82, 27, 14]);
    .add-column('Orbital period (days)', [365.256, 87.969, 224.701, 686.971, 4332.59, 10_759.22, 30_688.5, 60_182.0]);
    .add-column('Surface gravity (m/s)', [9.806, 3.7, 8.87, 3.721, 24.79, 10.44, 8.69, 11.15]);
}

$table.title('Planets in the Solar System');
$table.align(%(:Planet<l>));
$table.float-format(%('Orbital period (days)' => '-10.3f', 'Surface gravity (m/s)' => '-5.3f'));
$table.sort-by('Position');

say $table;

say "\n\nMarkdown formatted, with aligned columns via .set-style('MARKDOWN')\nNote the lack of Title too.\n\n";

$table = Prettier::Table.new:
    title => "Australian Cities",
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    align => %('City name' => 'l', 'Annual Rainfall'=>'r'),
    sort-by => 'Annual Rainfall',
;
$table.set-style('MARKDOWN');
add-australian-city-data($table);


say $table;

say "\n\nMS Word Friendly formatted, with aligned columns via .set-style('MSWORD-FRIENDLY')\n\n";

$table = Prettier::Table.new:
    title => "Australian Cities",
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    sort-by => 'Area',
    align => %('City name' => 'l'),
;
$table.set-style('MSWORD-FRIENDLY');
add-australian-city-data($table);

say $table;
