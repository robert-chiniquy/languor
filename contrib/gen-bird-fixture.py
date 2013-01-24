#! /usr/bin/env python

import xml.etree.ElementTree as etree

class Taxon:
  english_name = None
  latin_name = None

  def name(self):
    if self.english_name is not None:
      return '"'+ self.english_name +'"'
    elif self.latin_name is not None:
      return '"'+ self.latin_name +'"'
    return None

  def insert_line(self):
    r = None
    if len(self.children) > 0 and self.name is not None:
      r = 'insert(' + self.name() + ', ' + ', '.join([c.name() for c in self.children if c.name() is not None]) + ')';
    return r

  def print_insert_lines(self):
    if self.insert_line() is not None:
      print self.insert_line()
      for c in self.children:
        c.print_insert_lines()

  def __init__(self, node):
    self.children = []
    ln = node.find('latin_name')
    en = node.find('english_name')
    if ln is not None:
      self.latin_name = ln.text.title()
    if en is not None:
      self.english_name = en.text.title()
    if self.subtaxon is not None:
      child_nodes = node.findall(self.subtaxon.__name__)
      for child in child_nodes:
        self.children.append(self.subtaxon(child))

class subspecies(Taxon):
  subtaxon = None

class genus(Taxon):
  subtaxon = subspecies

class family(Taxon):
  subtaxon = genus

class order(Taxon):
  subtaxon = family

# http://www.worldbirdnames.org/ioc-lists/master-list/
# http://www.worldbirdnames.org/master_ioc-names-3.2_xml.zip
# $ LC_ALL='C' sed -ie 's/\<I\>//g;s/\<\/I\>//g' ioc-names-3.2.xml
doc = etree.parse('ioc-names-3.2.xml')
orders = [order(o) for o in doc.getroot()[0].findall('order')]
for o in orders:
  o.print_insert_lines()

print 'insert("orders", '+ ', '.join([o.name() for o in orders if o.name() is not None]) +')'
