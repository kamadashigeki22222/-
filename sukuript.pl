#merge
#とりあえず頻度順に並び替えた滞在Hex群のファイルをぶちこめ
use strict;
use warnings;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use kasai_program::LifelogEditor::GPXEdit;
use kasai_program::LifelogEditor::GeoUtil;
use kasai_program::new_dwell.pl;

#require 'kasai_program/new_dwell.pl';
