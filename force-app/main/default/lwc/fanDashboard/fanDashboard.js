import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

import getActiveSubscription from '@salesforce/apex/FanContentService.getActiveSubscription';
import getNoticiasByNivel from '@salesforce/apex/FanContentService.getNoticiasByNivel';
import getProductosByNivel from '@salesforce/apex/FanContentService.getProductosByNivel';
import searchNoticias from '@salesforce/apex/FanContentService.searchNoticias';

import { NavigationMixin } from 'lightning/navigation';

const USER_FIELDS = ['User.ContactId'];

export default class FanDashboard extends NavigationMixin(LightningElement) {

    @track subscription;
    @track noticias = [];
    @track productos = [];
    @track contactId;
    @track loading = true;
    @track error;
    @track searchText = '';

    wiredSubscriptionResult;
    wiredNoticiasResult;
    wiredProductosResult;

    @wire(getRecord, { recordId: USER_ID, fields: USER_FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.contactId = data.fields.ContactId.value;
        } else if (error) {
            this.error = error.body.message;
            this.loading = false;
        }
    }

    @wire(getActiveSubscription, { contactId: '$contactId' })
    wiredSubscription(result) {
        this.wiredSubscriptionResult = result;
        const { data, error } = result;
        if (data) {
            this.subscription = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getNoticiasByNivel, { contactId: '$contactId' })
    wiredNoticias(result) {
        this.wiredNoticiasResult = result;
        const { data, error } = result;
        if (data) {
            this.noticias = data;
            this.loading = false;
        } else if (error) {
            this.error = error.body.message;
            this.loading = false;
        }
    }

    @wire(getProductosByNivel, { contactId: '$contactId' })
    wiredProductos(result) {
        this.wiredProductosResult = result;
        const { data, error } = result;
        if (data) {
            this.productos = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    handleSearchInput(event) {
        this.searchText = event.target.value;
    }

    async handleSearch() {
        this.loading = true;
        try {
            const results = await searchNoticias({ searchText: this.searchText });
            this.noticias = results;
        } catch (err) {
            this.error = err.body.message;
        }
        this.loading = false;
    }

    get hasSubscription() {
        return this.subscription != null;
    }

    get nivel() {
        return this.subscription?.Nivel__c || '';
    }

    get fechaRenovacion() {
        return this.subscription?.Fecha_Renovacion__c || '';
    }

    handleRefresh() {
        this.loading = true;
        Promise.all([
            refreshApex(this.wiredSubscriptionResult),
            refreshApex(this.wiredNoticiasResult),
            refreshApex(this.wiredProductosResult)
        ]).finally(() => {
            this.loading = false;
        });
    }

    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/SiteLogin'
            }
        });
    }

    navigateToRegister() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/SiteRegister'
            }
        });
    }
}