# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import LiveServerTestCase
from selenium.webdriver.firefox.webdriver import WebDriver


class SimpleTests(LiveServerTestCase):
    #fixtures = ['user-data.json']
    
    @property
    def live_server_url(self):
        return 'http://%s:%s' % (
            self.server_thread.host, self.server_thread.port)

    @classmethod
    def setUpClass(cls):
        cls.selenium = WebDriver()
        super(SimpleTests, cls).setUpClass()
        
    
    def setUp(self):
        from django.contrib.sites.models import Site
        site = Site.objects.all()[0]
        site.domain = '%s:%s' % (self.server_thread.host, self.server_thread.port)
        site.save()

    @classmethod
    def tearDownClass(cls):
        cls.selenium.quit()
        super(SimpleTests, cls).tearDownClass()
        
    def form_input(self, name, value):
        self.selenium.find_element_by_name(name).send_keys(value)
        
    def t_est_login(self):
        self.create_user('newuser@gmail.com', 'g')
        self.login_user('newuser@gmail.com', 'g')
        self.assertIn('logout', self.selenium.page_source)
    
    def t_est_create_user(self):
        self.create_user('newuser@gmail.com', 'g')
        self.assertIn('alert alert-success alert-dismissable', self.selenium.page_source)
        
    def login_user(self, email, password):
        self.selenium.get('%s%s' % (self.live_server_url, '/login/'))
        self.form_input("username", email)
        self.form_input("password", password)
        self.selenium.find_element_by_xpath('//button[@type="submit"]').click()
    
    def logout_user(self):
        self.selenium.get('%s%s' % (self.live_server_url, '/logout/'))
    
    def create_user(self, email, password, first_name='Firstname', last_name='Lastname'):
        self.selenium.get('%s%s' % (self.live_server_url, '/signup/'))
        self.form_input("email", email)
        self.form_input("password1", password)
        self.form_input("password2", password)
        self.form_input("first_name", first_name)
        self.form_input("last_name", last_name)
        self.selenium.find_element_by_xpath('//button[@type="submit"]').click()
    
    def accept_tos(self):
        self.selenium.find_element_by_xpath('//input[@type="checkbox"]').click()
        self.selenium.find_element_by_xpath('//button[@data-value="tos_accepted:true"]').click()
    
    def create_project(self, name):
        self.selenium.get('%s%s' % (self.live_server_url, '/projects/add/'))
        self.form_input('name', name)
        self.selenium.find_element_by_xpath('//button[@type="submit"]').click()
    
    
    def test_round_trip(self):
        username = 'newuser@gmail.com'
        password = '***'
        project_name = 'Baggerfahren'
        
        self.create_user(username, password)
        self.assertIn('alert alert-success alert-dismissable', self.selenium.page_source)
        
        self.login_user(username, password)
        self.assertIn('logout', self.selenium.page_source)
        
        self.accept_tos()
        
        self.create_project(project_name)
        self.assertIn('alert alert-success alert-dismissable', self.selenium.page_source)
        
        self.selenium.get('%s%s' % (self.live_server_url, '/projects/'))
        self.assertIn(project_name, self.selenium.page_source)
        
        self.logout_user()
        self.assertIn('login', self.selenium.page_source)
