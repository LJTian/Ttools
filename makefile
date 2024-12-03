all: install
install:
	@mkdir -p /usr/local/Ttools/
	@cp *.sh /usr/local/Ttools/
	@chmod +x /usr/local/Ttools/*.sh
	@echo "export PATH=/usr/local/Ttools:$$PATH" >> /etc/profile
	@echo ""
	@echo "请运行:"
	@echo "	source /etc/profile && Ttools_test.sh " 
	@echo ""
uninstall:
	@rm -rf /usr/local/Ttools/
	@sed -i '/Ttools/d' /etc/profile
	@echo ""
	@echo "卸载完成..."
	@echo ""
